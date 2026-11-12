# 7. From a working model to an efficient, distributed, deployable system

[Previous](06-advanced-autograd-and-ai-objectives.md) · [Course index](../README.md)

## Correctness is the reference for optimization

A model that trains correctly on one process is a useful reference. Performance work should preserve its intended behavior while improving a measured constraint: latency, throughput, memory, cost, or recovery time. These constraints are related but different. A larger inference batch can increase throughput while making one request wait longer. Compilation can improve repeated execution while adding cold-start cost. Distributed training can process more data while introducing communication and coordination overhead.

This chapter introduces measurement, mixed precision, accumulation, compilation, distributed data parallelism, sharding, export, quantization, and deployment. It ends with a complete artifact-and-inference capstone. Advanced features depend strongly on hardware and installed versions, so examples state their environment requirements and avoid claiming unmeasured speedups.

## 7.1 Find the bottleneck before changing code

A training iteration includes loading examples, transforming them, copying batches, running forward, computing loss, running backward, and updating parameters. Low GPU utilization may mean the model is small, data loading is slow, the workload synchronizes often, or communication dominates. Increasing model width is not a principled response to an unknown bottleneck.

Measure complete iteration time and separate major phases when possible. Include warmup because initial allocations, kernel selection, and compilation can make early calls atypical. For a service, measure preprocessing and output conversion as well as model execution. A network-only benchmark does not establish end-to-end request latency.

On CUDA, operations are often asynchronous relative to Python. A timer around a launch can finish before device work completes. Synchronize at measurement boundaries or use appropriate device events. Synchronizing every operation would distort the workload, so do it deliberately rather than scattering calls through production code.

```python
import time
import torch
from torch import nn

device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
model = nn.Sequential(nn.Linear(128, 256), nn.ReLU(), nn.Linear(256, 32)).to(device).eval()
features = torch.randn(64, 128, device=device)
with torch.inference_mode():
    for _ in range(10):
        model(features)
    if device.type == 'cuda':
        torch.cuda.synchronize()
    start = time.perf_counter()
    for _ in range(100):
        model(features)
    if device.type == 'cuda':
        torch.cuda.synchronize()
    elapsed = time.perf_counter() - start
print('Mean seconds per call:', elapsed / 100)
```

This is a basic steady-state microbenchmark, not a complete service benchmark. CPU thread settings, background load, and device power state can influence results. Compare alternatives under the same conditions and repeat enough to distinguish variation from a real effect.

## 7.2 Profiling reveals operations and memory

A profiler records events associated with execution. Operator tables can identify expensive matrix multiplications, copies, or many tiny operations. Shape recording and memory profiling add information but also overhead. Use short representative windows rather than profiling an entire multi-day run.

```python
import torch
from torch import nn
from torch.profiler import profile, ProfilerActivity

model = nn.Sequential(nn.Linear(64, 128), nn.ReLU(), nn.Linear(128, 8))
features = torch.randn(32, 64)
with profile(activities=[ProfilerActivity.CPU], record_shapes=True) as profiler:
    for _ in range(5):
        model(features).square().mean().backward()
        model.zero_grad(set_to_none=True)
print(profiler.key_averages().table(sort_by='self_cpu_time_total', row_limit=8))
```

The program profiles CPU execution and includes backward. A CUDA workload should include CUDA activity when available and supported. An operator with high total time may contain expensive child operations, while self time excludes them. Read the table's definitions before attributing cost.

Profiling suggests hypotheses. If copies dominate, inspect device movement and data layout. If many tiny launches dominate, batching or fusion may help. If one large matrix multiplication dominates, a different dtype or architecture may matter. Reprofile after one change so you can connect the observed result to its cause.

## 7.3 Understand what consumes training memory

Training stores parameters, gradients, optimizer state, saved activations, temporary workspaces, and possibly communication buffers. A parameter-count estimate covers only part of this. Adam-style optimizers keep additional state per parameter, and activations can dominate for large batches or long sequences.

Memory reported as reserved by a caching allocator differs from memory occupied by live tensors. Returning a tensor's storage to a cache can make it reusable without returning it immediately to the device driver. A high reserved figure alone is not evidence of a leak. Track allocated live memory and iteration behavior before diagnosing retention.

Typical remedies target specific components. Reducing batch size reduces many activations. Gradient accumulation can recover a larger effective batch across several passes. Activation checkpointing trades extra computation for fewer saved intermediates. Sharding reduces replicated state. Lower precision can reduce some storage and bandwidth. None is universally best.

Activation checkpointing recomputes selected forward regions during backward rather than retaining all intermediates. This requires compatible recomputation behavior; random operations and side effects need care. It also changes performance, so choose boundaries where memory savings justify extra work. Use the current checkpointing API with its documented options rather than copying an old recipe blindly.

## 7.4 Mixed precision chooses numerical formats by operation

Some accelerator operations run faster in lower precision, while reductions and sensitive calculations may benefit from float32. Autocast selects eligible operation dtypes within a region. It is different from converting the entire model and every input to half precision indiscriminately.

Float16 has a narrower exponent range than float32, so small gradients can underflow. Gradient scaling multiplies the loss before backward and later unscales gradients before the optimizer update. Bfloat16 has a wider exponent range with fewer precision bits, often changing the need for scaling, but hardware support and numerical behavior still matter.

The next complete single-step example requires a CUDA device and uses the current `torch.amp` scaler interface. It deliberately does not combine compilation and autocast; verify the installed release's compiled-backward semantics before composing those features.

```python
import torch
from torch import nn

if not torch.cuda.is_available():
    raise RuntimeError('This mixed-precision example requires CUDA')
model = nn.Linear(16, 4).cuda()
optimizer = torch.optim.AdamW(model.parameters(), lr=1e-3)
scaler = torch.amp.GradScaler('cuda')
features = torch.randn(32, 16, device='cuda')
targets = torch.randint(0, 4, (32,), device='cuda')
optimizer.zero_grad(set_to_none=True)
with torch.autocast(device_type='cuda', dtype=torch.float16):
    logits = model(features)
    loss = nn.functional.cross_entropy(logits, targets)
scaler.scale(loss).backward()
scaler.unscale_(optimizer)
nn.utils.clip_grad_norm_(model.parameters(), max_norm=1.0)
scaler.step(optimizer)
scaler.update()
print(loss.detach().item())
```

Clipping follows unscaling so its threshold applies to actual gradients rather than artificially scaled ones. The scaler can skip an update when it detects nonfinite gradients. Track that behavior when diagnosing training, rather than assuming every call to `step` performed a parameter update.

Compare mixed-precision results with a float32 reference on representative cases. A small numerical difference is expected; a changed decision or unstable objective may be unacceptable. Keep numerically sensitive custom losses in an appropriate dtype and inspect the earliest failing intermediate.

## 7.5 Gradient accumulation requires the correct denominator

If one large batch does not fit, process several microbatches before stepping the optimizer. Gradients accumulate naturally, but each microbatch's contribution must be scaled to match the intended combined objective. Dividing every microbatch mean by a fixed count works only when all microbatches in the accumulation group have equal effective size and the group count is correct.

For unequal sizes, sum unreduced example losses and divide each contribution by the total examples in the group. Then all contributions add to the same gradient as the combined average, assuming no batch-dependent operations or other differences in computation.

```python
import torch
from torch import nn

model = nn.Linear(2, 1)
optimizer = torch.optim.SGD(model.parameters(), lr=0.01)
microbatches = [
    (torch.randn(3, 2), torch.randn(3)),
    (torch.randn(2, 2), torch.randn(2)),
]
total_examples = sum(len(targets) for _, targets in microbatches)
optimizer.zero_grad(set_to_none=True)
for features, targets in microbatches:
    prediction = model(features).squeeze(-1)
    contribution = (prediction - targets).square().sum() / total_examples
    contribution.backward()
optimizer.step()
```

This example stores a group explicitly to make its denominator visible. A streaming loader can calculate group sizes or use a carefully defined final-group policy. For token objectives, use valid-token counts. Dropout randomness and batch normalization can make accumulated microbatches differ from one physical large batch even when gradient scaling is correct.

When combining with AMP, keep one scale across an accumulation group and unscale only after all contributions are accumulated. When combining with distributed training, synchronization policy adds another layer. Compose features only after verifying each independently.

## 7.6 Compilation changes execution strategy

`torch.compile` attempts to optimize a function or module through the PyTorch compiler stack. It can fuse operations and reduce overhead for suitable workloads. The first calls can include substantial compilation work, and changing shapes or Python conditions can cause specialization and recompilation.

```python
import torch
from torch import nn

torch.manual_seed(79)
eager = nn.Sequential(nn.Linear(8, 16), nn.ReLU(), nn.Linear(16, 2)).eval()
features = torch.randn(4, 8)
compiled = torch.compile(eager)
with torch.no_grad():
    expected = eager(features)
    actual = compiled(features)
assert torch.allclose(expected, actual, atol=1e-5, rtol=1e-4)
print(actual.shape)
```

This example requires a supported compiler installation and backend. It demonstrates parity, not a speed claim. Benchmark after warmup and include startup cost if the process will execute only a few requests. A short-lived command can be slower overall even when steady-state execution improves.

Graph breaks occur when part of the computation cannot be captured and execution returns to eager Python. Data-dependent scalar extraction, unsupported Python behavior, and side effects can interfere. `fullgraph=True` asks for a stricter capture contract and can help expose breaks, but it is not an automatic optimization setting for every model.

Compiler and autocast behavior evolves. The consulted AMP documentation specifically includes compiled-backward context considerations. Preserve an eager reference and verify loss values and gradients when combining compilation with mixed precision or custom autograd. Avoid reaching for private configuration knobs without a release-specific reason and documentation.

## 7.7 Distributed data parallelism replicates the model

Distributed data parallelism, or DDP, ordinarily runs one process per device. Each process holds a model replica, computes gradients on its local batch, and participates in gradient synchronization. All replicas then apply compatible updates. This increases data throughput when computation is large enough to justify communication.

DDP does not automatically divide a dataset among processes. A distributed sampler or another explicit partitioning scheme provides different examples to each rank. Rank is a process identifier within a process group. World size is the number of participating processes. Local rank commonly identifies a device within one machine.

The global effective batch size is local batch size multiplied by world size and, if applicable, accumulation count. Changing world size therefore changes optimization unless another quantity is adjusted. Learning rate scaling is an experimental choice rather than a requirement built into the mathematical definition.

All ranks must execute compatible collective operations. If one process exits early while others wait for gradient communication, the job can hang. Data-dependent control flow, uneven iteration counts, and rank-specific exceptions deserve careful design. Start with a small complete two-process example before scaling a real training job.

## 7.8 A complete CPU DDP demonstration

Save this program as `ddp_cpu.py` and launch it with the following command on a platform with a supported Gloo distributed build:

```bash
torchrun --standalone --nproc_per_node=2 ddp_cpu.py
```

The program uses CPU so the distributed mechanism can be explored without multiple GPUs. It is a correctness demonstration, not a CPU scaling recommendation.

```python
import torch
from torch import nn
import torch.distributed as dist
from torch.nn.parallel import DistributedDataParallel
from torch.utils.data import TensorDataset, DataLoader, DistributedSampler

def main():
    dist.init_process_group(backend='gloo')
    try:
        rank = dist.get_rank()
        torch.manual_seed(83)
        features = torch.randn(64, 2)
        targets = 2 * features[:, 0] - features[:, 1]
        dataset = TensorDataset(features, targets)
        sampler = DistributedSampler(dataset, shuffle=True, drop_last=False)
        loader = DataLoader(dataset, batch_size=8, sampler=sampler)
        model = DistributedDataParallel(nn.Linear(2, 1))
        optimizer = torch.optim.SGD(model.parameters(), lr=0.05)
        for epoch in range(10):
            sampler.set_epoch(epoch)
            model.train()
            local_sum = torch.zeros((), dtype=torch.float64)
            local_count = torch.zeros((), dtype=torch.float64)
            for batch_x, batch_y in loader:
                optimizer.zero_grad(set_to_none=True)
                residual = model(batch_x).squeeze(-1) - batch_y
                loss = residual.square().mean()
                loss.backward()
                optimizer.step()
                local_sum += residual.detach().square().sum().double()
                local_count += len(batch_y)
            dist.all_reduce(local_sum, op=dist.ReduceOp.SUM)
            dist.all_reduce(local_count, op=dist.ReduceOp.SUM)
            if rank == 0:
                print(epoch, (local_sum / local_count).item())
        if rank == 0:
            torch.save(model.module.state_dict(), 'ddp-weights.pt')
    finally:
        dist.destroy_process_group()

if __name__ == '__main__':
    main()
```

The sampler receives a new epoch so shuffling changes across epochs. The example count is divisible by world size, avoiding sampler-padding duplicates in this demonstration. Metric sums and counts are reduced globally; averaging rank-local means would require equal counts to be correct. Only rank zero writes the checkpoint, and the underlying module's state avoids adding the wrapper's naming prefix.

For CUDA, select the local device before constructing and wrapping the model, use the appropriate supported backend, and pass device IDs under the documented DDP pattern. Do not simply replace every CPU string without understanding process-to-device mapping. Multi-node execution adds rendezvous, network reachability, and launch configuration, which are environment-specific concerns.

## 7.9 Distributed evaluation must count unique examples

A distributed sampler may pad a dataset with repeated indices so every rank receives equal length. That can be convenient for training and can bias evaluation if repeated examples are counted as independent. Use an evaluation partitioning strategy that preserves unique counts, or explicitly remove duplicate contributions.

Some ranks may have different evaluation lengths. If using a DDP-wrapped module whose forward performs collectives such as buffer broadcasts, uneven numbers of forward calls can cause synchronization problems. One practical strategy is a carefully designed evaluation path on the underlying replicated model with appropriately synchronized state, followed by reduction of final metric statistics.

For decomposable metrics, reduce sufficient statistics such as error sums and counts. For ranking metrics, exact aggregation may require gathering predictions and targets or using a validated distributed implementation. Averaging local AUROC values generally does not equal global AUROC because ranking relationships cross rank boundaries.

Checkpoint and resumption policies also need rank awareness. A fully replicated model can often save one replica's weights, but random generators, sampler position, and optimizer state must match the resumption guarantee. Sharded training changes the state-storage problem further.

## 7.10 Sharding addresses replicated state

DDP normally replicates parameters and optimizer state across ranks. If a model's state does not fit on one device, merely adding DDP processes does not solve that memory problem. Fully sharded data parallelism distributes parameter-related state and gathers needed pieces around computation under its supported execution model.

Sharding trades memory replication for communication and coordination. Wrapping boundaries determine which parts are gathered together and how communication overlaps computation. A very large unsharded unit can still create a memory peak. Optimizer construction and checkpointing must follow the chosen API's rules because parameter representation changes.

The official FSDP2 tutorial is the appropriate hands-on continuation for the installed release. Its `fully_shard` workflow differs from older FSDP wrappers, so do not mix recipes across generations. This course teaches the decision and state model rather than presenting an untested hardware-specific cluster recipe as universally runnable.

Tensor parallelism partitions individual computations, such as a large projection, across devices. Pipeline parallelism partitions layers into stages. These address different constraints and can be combined in large systems. The right choice depends on model dimensions, interconnect, batch structure, and available memory, not only device count.

## 7.11 Export is a deployment contract

A state dictionary stores learned state but still needs Python architecture code. An exported program captures a tensor computation with specified input assumptions for downstream execution. Export is different from compiling a Python process for faster repeated calls. It places stronger constraints on representable computation and shape behavior.

```python
import torch
from torch import nn

model = nn.Sequential(nn.Linear(3, 8), nn.ReLU(), nn.Linear(8, 1)).eval()
example = torch.randn(2, 3)
program = torch.export.export(model, (example,))
torch.export.save(program, 'regressor.pt2')
loaded = torch.export.load('regressor.pt2')
with torch.no_grad():
    expected = model(example)
    actual = loaded.module()(example)
assert torch.allclose(expected, actual)
```

This example uses a fixed example shape. Supporting varying batch or sequence dimensions requires explicit dynamic-shape assumptions under the export API. Export success for one shape does not prove arbitrary shapes are supported. Test the actual runtime and input ranges the application will use.

ONNX provides another interchange path. Operator support, exporter options, opset, and target runtime compatibility must agree. An exported file is not validated merely because it exists. Compare predictions against the eager reference on representative inputs and measure behavior in the target runtime, including preprocessing and output interpretation.

## 7.12 Quantization trades numerical representation for efficiency

Quantization represents selected values using fewer bits with associated scales and possibly zero points. Weight-only quantization reduces weight storage and bandwidth. Activation quantization also changes intermediate representations. Post-training methods estimate needed statistics after fitting, while quantization-aware training simulates aspects of quantization during learning.

Lower bit width can reduce model size and improve speed on supported hardware, but may change accuracy and does not guarantee faster execution. Backend kernels, group size, outlier handling, and model structure matter. A quantized operation without an efficient target kernel can be slower than the original.

The current torchao documentation is the appropriate entry point for supported workflows. Quantization APIs and recommended routes have evolved, so this chapter avoids presenting a legacy one-liner as the universal modern recipe. Choose a documented method for the model and device, preserve the original artifact, and compare quality and latency under the same evaluation conditions.

Quantization changes the artifact's numerical behavior. Recheck rare cases, calibration, and error categories rather than only an aggregate score. If the application has tight numerical tolerances, establish those tolerances before optimization so acceptance is a concrete engineering decision.

## 7.13 A deployment function starts with input validation

A service receives ordinary data, not magically correct tensors. Validate required fields, feature ordering, units, finite values, shape, and supported batch size. Convert to tensors once the request is understood. Preserve the model's preprocessing and output mapping with the artifact.

Load the model once during process initialization where appropriate, set evaluation mode, and use an inference context for ordinary predictions. Reconstructing and loading a model on every request adds overhead and can create concurrency and consistency problems. Version the loaded artifact so logs can identify which model produced a result.

Batching can improve throughput, but queueing requests to form a batch introduces latency. A useful service policy balances maximum batch size and maximum wait. Measure tail latency, not only the average. Large requests should not indefinitely block small ones, and input limits should reflect memory constraints.

Inference mode can reduce overhead compared with ordinary autograd execution, but tensors created under it have restrictions when later used in differentiable computations. Keep standard prediction code separate from input-gradient analysis or adaptation. The correct mode depends on what the caller intends to do with the result.

## 7.14 A complete capstone: save, load, and verify predictions

This self-contained program builds a small regression model, includes fitted preprocessing as buffers, selects a validation checkpoint, saves a schema, reloads it on CPU, validates raw inputs, and checks prediction parity. It provides a concrete end-to-end artifact rather than only a list of capstone requirements.

```python
import copy
import math
from pathlib import Path
import torch
from torch import nn
from torch.utils.data import TensorDataset, DataLoader

class Predictor(nn.Module):
    def __init__(self, mean, scale, width=16):
        super().__init__()
        self.register_buffer('mean', mean.clone())
        self.register_buffer('scale', scale.clamp_min(1e-6).clone())
        self.network = nn.Sequential(nn.Linear(2, width), nn.Tanh(), nn.Linear(width, 1))
    def forward(self, features):
        return self.network((features - self.mean) / self.scale).squeeze(-1)

@torch.no_grad()
def mse(model, features, targets):
    model.eval()
    return (model(features) - targets).square().mean().item()

def load_predictor(path):
    artifact = torch.load(path, map_location='cpu', weights_only=True)
    if artifact['schema_version'] != 1:
        raise ValueError('Unsupported artifact schema')
    if artifact['feature_names'] != ['area', 'temperature']:
        raise ValueError('Unexpected feature contract')
    state = artifact['model_state']
    model = Predictor(torch.zeros(2), torch.ones(2), width=artifact['width'])
    model.load_state_dict(state)
    return model.eval()

@torch.inference_mode()
def predict_rows(model, rows):
    values = torch.as_tensor(rows, dtype=torch.float32)
    if values.ndim != 2 or values.shape[1] != 2 or values.shape[0] == 0:
        raise ValueError('Expected nonempty rows [area, temperature]')
    if not torch.isfinite(values).all():
        raise ValueError('Inputs must be finite')
    return model(values).tolist()

def main():
    torch.manual_seed(89)
    generator = torch.Generator().manual_seed(97)
    features = torch.randn(500, 2, generator=generator)
    targets = 1.5 * features[:, 0] - 0.7 * features[:, 1]
    targets += 0.2 * features[:, 0].square()
    targets += 0.05 * torch.randn(500, generator=generator)
    train_x, train_y = features[:350], targets[:350]
    val_x, val_y = features[350:425], targets[350:425]
    test_x, test_y = features[425:], targets[425:]
    model = Predictor(train_x.mean(0), train_x.std(0, correction=0))
    optimizer = torch.optim.AdamW(model.parameters(), lr=0.01, weight_decay=1e-4)
    loader = DataLoader(TensorDataset(train_x, train_y), batch_size=32, shuffle=True)
    best_metric, best_state = math.inf, None
    for epoch in range(60):
        model.train()
        for batch_x, batch_y in loader:
            optimizer.zero_grad(set_to_none=True)
            loss = (model(batch_x) - batch_y).square().mean()
            if not torch.isfinite(loss):
                raise FloatingPointError('Nonfinite objective')
            loss.backward()
            optimizer.step()
        metric = mse(model, val_x, val_y)
        if metric < best_metric:
            best_metric, best_state = metric, copy.deepcopy(model.state_dict())
    model.load_state_dict(best_state)
    model.eval()
    print('Test MSE:', mse(model, test_x, test_y))
    baseline = (test_y - train_y.mean()).square().mean().item()
    print('Training-mean baseline MSE:', baseline)
    artifact = {'schema_version': 1, 'width': 16,
                'feature_names': ['area', 'temperature'],
                'model_state': model.state_dict()}
    path = Path('capstone-model.pt')
    torch.save(artifact, path)
    restored = load_predictor(path)
    reference_rows = [[0.0, 0.0], [1.0, -1.0], [-0.5, 0.8]]
    expected = torch.tensor(predict_rows(model, reference_rows))
    actual = torch.tensor(predict_rows(restored, reference_rows))
    assert torch.allclose(expected, actual, atol=1e-6, rtol=1e-5)
    print('Reload parity passed:', actual.tolist())
    try:
        predict_rows(restored, [[float('nan'), 0.0]])
    except ValueError:
        print('Invalid-input rejection passed')
    else:
        raise AssertionError('Expected invalid-input rejection')

if __name__ == '__main__':
    main()
```

The feature names describe a contract for this synthetic example; values are generated standardized-scale measurements, not a real building dataset. A production artifact would include actual units, range expectations, data lineage, and task metadata. The example keeps all computation on CPU to make save-and-reload behavior easy to reproduce.

The parity assertion checks that saving and loading preserve reference predictions. The invalid-input check verifies a meaningful boundary behavior. Neither establishes real-world model quality. That requires a representative dataset and evaluation policy such as the one developed in Chapter 3.

## 7.15 Monitoring preserves the meaning of deployment

Track input distributions, missingness, invalid requests, latency, output distributions, and observed outcomes when they become available. An input shift does not automatically mean accuracy declined, and unchanged input summaries do not prove accuracy stayed constant. Label-based evaluation remains important when feasible.

Keep model and preprocessing versions together. If a new tokenizer or normalization transform changes, deploy it as part of the same versioned system. Retain a rollback path to a known artifact and define the evidence needed to promote a replacement. These are engineering practices that protect the meaning of the trained computation.

A service can fail even when predictions are numerically valid. Queueing, memory growth, artifact mismatches, and malformed inputs are operational failures. Include these in integration checks instead of treating deployment as merely calling `model(inputs)` inside an HTTP handler.

## 7.16 A final method for learning unfamiliar PyTorch features

When encountering a new feature, ask what problem it solves, which mathematical behavior it preserves, which state it introduces, and which environment assumptions it requires. Build the smallest example that exposes its contract. Compare it with a clear reference before combining it with other advanced features.

This method scales beyond the specific APIs in the course. You now have the tools to read tensors, derive objectives, trace gradients, design experiments, understand common architectures, and evaluate execution changes. Continuing study should deepen a concrete application rather than requiring memorization of every function in a large library.

## 7.17 Data transfer is part of the execution pipeline

A loader prepares batches on CPU while the training process executes on a device. Pinned host memory can support efficient asynchronous copies on CUDA under suitable conditions. A nonblocking copy request expresses permission to avoid blocking where supported; it is not a guarantee that useful overlap actually occurs.

Begin with a correct loader, then benchmark `pin_memory` and transfer options for the actual workload. Very small batches or expensive preprocessing may not benefit. Creating pinned memory manually inside a hot loop can cost more than it saves. Memory lifetime and synchronization also matter: do not overwrite a source buffer before a pending transfer has safely consumed it.

Persistent workers avoid recreating worker processes for each loader iteration, but are meaningful only with a positive worker count. Prefetching can keep a device busy while increasing memory use. Dataset objects that retain large Python structures may be duplicated or shared differently depending on the multiprocessing method. Measure resident memory as well as throughput.

The first practical optimization is often reducing avoidable work: decode once where appropriate, cache deterministic expensive transforms with a clear invalidation policy, batch operations, and avoid repeated device round trips. Keep random augmentation separate from deterministic caches so the cache does not accidentally freeze the intended training variation.

## 7.18 A minimal local inference endpoint

An HTTP endpoint is an adapter around the predictor, not part of the learning algorithm. The following program uses Python's standard library for a local demonstration. Save the capstone program from Section 7.14 as `capstone.py`, run it to create `capstone-model.pt`, and put this program beside it as `serve_local.py`. This is a complete integration example with that explicit file dependency.

```python
import json
from http.server import BaseHTTPRequestHandler, HTTPServer
from capstone import load_predictor, predict_rows

model = load_predictor('capstone-model.pt')

class Handler(BaseHTTPRequestHandler):
    def do_POST(self):
        if self.path != '/predict':
            self.send_error(404)
            return
        try:
            length = int(self.headers.get('Content-Length', '0'))
            if length <= 0 or length > 65536:
                raise ValueError('Invalid request length')
            payload = json.loads(self.rfile.read(length))
            rows = payload['rows']
            if not isinstance(rows, list) or len(rows) > 256:
                raise ValueError('Invalid batch')
            predictions = predict_rows(model, rows)
            body = json.dumps({'model_version': 1, 'predictions': predictions}).encode()
        except (ValueError, TypeError, KeyError, OverflowError):
            self.send_error(400, 'Invalid prediction request')
            return
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Content-Length', str(len(body)))
        self.end_headers()
        self.wfile.write(body)

if __name__ == '__main__':
    print('Local demo listening on http://127.0.0.1:8000/predict')
    HTTPServer(('127.0.0.1', 8000), Handler).serve_forever()
```

The request body is a JSON object whose `rows` field contains ordered pairs, such as `{"rows": [[0.0, 0.0], [1.0, -1.0]]}`. The response contains one prediction per row. The server binds only to the local machine and loads one artifact at startup. It is a teaching server, not a production hosting stack; concurrent workers, authentication, transport security, structured observability, and lifecycle management belong in a real deployment design.

The endpoint delegates numerical validation to the predictor and adds request-size and batch-size limits. That division keeps the mathematical input contract reusable from a command-line script, test, or web adapter. A different web framework should not redefine feature order or preprocessing.

## 7.19 Orchestration turns stages into repeatable jobs

A machine learning workflow has stages with identifiable inputs and outputs: prepare a dataset revision, train a candidate, evaluate it, package an artifact, and make a deployment decision. An orchestrator schedules those stages, tracks dependencies, and handles retries. It does not decide whether the learning problem or evaluation criterion is valid.

A useful stage is repeatable and explicit about side effects. Preparing the same dataset revision should not create a different split on every retry. Training should write a candidate artifact under a unique run identity rather than overwrite a deployed artifact. Evaluation should reference the exact candidate and evaluation dataset. Packaging should preserve those identities.

Retries require idempotency or another clear policy. Retrying a download can reuse verified bytes. Retrying a deployment request should not create duplicate versions unpredictably. A partially written artifact should not be considered ready merely because its filename exists. Use completion markers, checksums, or atomic publication where the storage system supports them.

External tools such as Airflow and Prefect can implement these dependencies, but their APIs and deployment assumptions change. The underlying design can first be expressed as ordinary Python functions or separate command-line programs with explicit artifact paths. Once those stages are reliable, choose an orchestrator based on scheduling, infrastructure, recovery, and team requirements. That keeps framework adoption from hiding an undefined workflow.

## 7.20 A promotion decision needs more than a drift alarm

Prediction distributions can change because the population changed, the service received a different mix of requests, or the model changed. A drift statistic is a signal to investigate. It does not prove that retraining will help, nor that a newly trained model is better.

A candidate should pass the same input-contract and parity checks as the existing model, then be compared on representative labeled data and relevant operational measurements. Examine key subgroups and known failure cases. If labels arrive slowly, state which conclusions remain provisional and what monitoring will provide later evidence.

Keep a stable rollback artifact and a way to associate outcomes with the version that produced them. A gradual rollout can expose operational issues before full traffic uses the candidate, but its comparison must account for traffic allocation and time effects. Deployment methodology is another experimental design problem.

The practical conclusion is that automation should make a defined process repeatable. It should not turn one arbitrary threshold into a claim of model quality. The course's first-principles approach applies here as much as to gradients: identify what the measurement means, the assumptions behind the action, and the evidence that will show whether it worked.

## 7.21 A numerical memory budget before a scaling decision

Consider a model with one hundred million parameters. Storing each in float32 requires about four hundred million bytes before gradients or optimizer state. A same-sized gradient adds another such amount. Two float32 moment tensors add approximately eight hundred million more bytes. This rough accounting already reaches about 1.6 billion bytes without activations, temporary buffers, or allocator overhead.

The estimate is intentionally simplified. Mixed-precision methods may retain master weights, different optimizer implementations organize state differently, and sharded systems distribute ownership. Its value is showing why a model file's size does not predict training memory. If long-sequence activations dominate, sharding parameter state may save less than expected. If optimizer state dominates, activation checkpointing alone may be insufficient.

Write a budget for the actual model and batch before choosing a scaling mechanism. Then measure a representative step and compare observed peaks with the estimate. Differences often reveal hidden copies, saved activations, or optimizer initialization that occurs only after the first update. A budget turns “out of memory” from an opaque failure into an identifiable resource mismatch.

## 7.22 Extending the capstone into a real project

Choose one concrete task rather than adding every advanced feature at once. Replace generated observations with a dataset you are permitted to use. Define its independent observation unit, feature schema, target meaning, split policy, and baseline. Keep the artifact-loading and parity checks while adapting the model architecture.

After establishing held-out quality, measure one operational constraint. If inference latency is acceptable, compilation may not be needed. If training fits comfortably on one device, distributed execution may add complexity without benefit. If a frozen representation meets the task requirements, full fine-tuning may be unnecessary. Each feature should solve an observed problem.

A strong final project therefore contains both a working model and a defensible explanation: what it predicts, how its objective relates to that prediction, what evidence supports its performance, how its artifact reproduces inference, and which conditions remain outside its evaluation. That explanation is the culmination of the tensor, mathematical, modeling, and engineering foundations developed throughout these chapters.

Keep the first project small enough that you can explain every transformation from raw observation to reported prediction. Expanding from that verified foundation is easier than debugging a large system assembled from unrelated recipes. The saved reference examples become a durable way to detect regressions while your implementation and understanding grow.

## Sources

Official references: [profiler recipe](https://docs.pytorch.org/tutorials/recipes/recipes/profiler_recipe.html), [AMP](https://docs.pytorch.org/docs/2.15/amp.html), [compile](https://docs.pytorch.org/docs/2.15/generated/torch.compile.html), [DDP](https://docs.pytorch.org/docs/2.15/generated/torch.nn.parallel.DistributedDataParallel.html), [FSDP2 tutorial](https://docs.pytorch.org/tutorials/intermediate/FSDP_tutorial.html), [export overview](https://docs.pytorch.org/docs/main/user_guide/torch_compiler/export.html), [ONNX](https://docs.pytorch.org/docs/2.15/onnx.html), and [torchao](https://docs.pytorch.org/ao/stable/index.html). Accessed November 12, 2026. The export overview resolved to the development documentation and is version-sensitive; check the installed stable release before deployment. The local HTTP adapter follows the standard [Python HTTP server interface](https://docs.python.org/3/library/http.server.html).
