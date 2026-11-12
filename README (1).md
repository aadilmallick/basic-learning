# Running the examples

The lesson files explain each program. Most examples use generated data and require only a working PyTorch installation. No exact learning curve is promised across environments.

| Script | Purpose | Requirements |
|---|---|---|
| `00_finite_difference.py` | Numerical derivative versus analytic slope | Python only |
| `01_scalar_gradient_descent.py` | Learning a scalar without autograd | Python only |
| `02_xor.py` | Complete nonlinear binary classifier | torch; CPU works |
| `03_regression_experiment.py` | Split, preprocessing buffers, validation selection, test metric, artifact | torch; CPU works |
| `03_hyperparameter_search.py` | Independent width/rate trials | torch; CPU works |
| `04_cnn_bars.py` | Complete CNN and generated image data | torch; CPU works |
| `05_tiny_transformer.py` | Character transformer training and sampling | torch with functional SDPA; CPU works, runtime varies |
| `05_low_rank_adapter.py` | Frozen projection plus trainable rank correction | torch; CPU works |
| `06_tiny_vae.py` | Reconstruction and latent KL on synthetic observations | torch; CPU works |
| `06_policy_gradient_bandit.py` | Reward learning through discrete samples | torch; CPU works |
| `06_diffusion_training_step.py` | Noise prediction training step | torch; CPU works; not a sampler |
| `06_custom_autograd.py` | Custom backward and numerical derivative check | torch; CPU works |
| `07_amp_cuda.py` | Autocast, scaling, unscaling, clipping | CUDA-enabled torch and supported GPU |
| `07_compile.py` | Eager/compiled parity | Supported compiler/backend |
| `07_export.py` | Fixed-shape export and reload parity | Compatible torch.export stack |
| `ddp_cpu.py` | Two-process gradient synchronization | torch distributed with Gloo and torchrun |
| `capstone.py` | Complete train/save/load/input-validation capstone | torch; CPU works |
| `serve_local.py` | Local JSON prediction adapter | torch; capstone artifact in current directory |
| `check_runtime.py` | Meaningful CPU forward/backward, masking, causality, artifact checks | torch; supplied for execution after installation |

## Ordinary programs

From the course root:

```bash
python examples/02_xor.py
python examples/04_cnn_bars.py
python examples/05_tiny_transformer.py
python examples/check_runtime.py
```

Training demonstrations can take appreciable time on CPU. Reduce only the step count for a quick mechanics check; that changes learning outcomes. The runtime-check program avoids full training and checks mathematical and integration properties.

## Distributed program

From the course root on a supported platform:

```bash
torchrun --standalone --nproc_per_node=2 examples/ddp_cpu.py
```

Do not run this script as an ordinary single-process Python file; its launcher supplies process-group environment variables.

## Capstone and local server

Keep the generated artifact and importable scripts together:

```bash
cd examples
python capstone.py
python serve_local.py
```

The server remains running until interrupted. It listens only on `127.0.0.1:8000`; it is a local teaching adapter. A POST to `/predict` accepts a body such as `{"rows": [[0.0, 0.0], [1.0, -1.0]]}`. This course does not launch the server automatically.

## What was executed during authoring

Only the two Python-only examples were executed. All scripts and all Python lesson blocks were syntax-checked. PyTorch runtime checks, training, CUDA, compilation, export, distributed execution, and server integration remain unexecuted in the authoring environment. See [validation](../VALIDATION.md).
