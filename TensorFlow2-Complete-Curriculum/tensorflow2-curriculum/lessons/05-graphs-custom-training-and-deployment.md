# Lesson 5 — Custom training, graphs, performance, and deployment

[Previous lesson](04-vision-sequences-attention-and-generative-models.md) · [Course index](../README.md)

## 1. Make implementation choices follow a concrete need

Keras's standard training interface is sufficient for many supervised problems. Custom code becomes valuable when the objective, update schedule, metrics, or model behavior genuinely differs from that interface. Examples include alternating GAN updates, contrastive objectives across several views, and scientific losses involving input derivatives.

Customization increases responsibility. You must preserve parameter tracking, correct loss reductions, training and inference behavior, metric lifecycle, serialization, and device placement. This chapter introduces those responsibilities one at a time. The aim is to understand the abstractions well enough to extend them without silently discarding their guarantees.

The source primer emphasizes code organization, initialization, saving, and the relationship between training and evaluation. We retain those concerns using TensorFlow 2 objects and functions. Sessions, placeholder feeds, global initializers, and variable-scope reuse are historical context rather than the preferred starting point for new code.

## 2. A custom layer owns behavior and parameters

A layer combines a mathematical operation with tracked state. Use `__init__` for configuration and child layers, `build` for weights that depend on input shape, and `call` for the forward computation. Creating a new variable on every call would produce an ever-changing parameter set rather than repeated use of one learned function.

```python
import tensorflow as tf
from tensorflow import keras

@keras.utils.register_keras_serializable(package="Course")
class Affine(keras.layers.Layer):
    def __init__(self, units, **kwargs):
        super().__init__(**kwargs)
        self.units = int(units)

    def build(self, input_shape):
        self.kernel = self.add_weight(
            name="kernel", shape=(input_shape[-1], self.units),
            initializer="glorot_uniform", trainable=True,
        )
        self.bias = self.add_weight(
            name="bias", shape=(self.units,),
            initializer="zeros", trainable=True,
        )
        super().build(input_shape)

    def call(self, inputs):
        return tf.matmul(inputs, self.kernel) + self.bias

    def get_config(self):
        return {**super().get_config(), "units": self.units}

layer = Affine(3)
print(layer(tf.ones([2, 4])).shape)  # (2, 3)
print(len(layer.trainable_variables))  # 2
```

The decorator gives the class a registered serialization identity when its defining module has been imported. `get_config` records constructor information. Saving a custom class is not the same as embedding arbitrary Python source code into a portable artifact; a fresh loading process generally needs the class registration code available.

`add_weight` makes Keras aware of ownership, trainability, and persistence. Assigning an ordinary `tf.Variable` to an attribute is not a universally safe substitute for Keras 3 tracking. Prefer the layer's supported creation mechanism. Parameters created in `build` use the observed input feature dimension and remain fixed thereafter.

If the last input dimension is unknown, this layer cannot create its matrix yet. That is a real contract requirement, not something to conceal with a guessed size. A layer that applies a feature matrix needs to know how many incoming features it has.

## 3. Training mode and trainability are separate controls

A trainable flag controls whether variables participate in ordinary training updates. A training-mode argument controls how the forward computation behaves. A frozen layer can still contain behavior affected by runtime mode, depending on the layer's semantics.

Dropout randomly suppresses activations during training and rescales retained values so the expected scale is maintained. It is disabled for ordinary inference. Batch normalization uses batch statistics during training and stored moving statistics during inference, with additional interactions between its trainable setting and behavior.

```python
import tensorflow as tf
from tensorflow import keras

class SmallNetwork(keras.Model):
    def __init__(self):
        super().__init__()
        self.hidden = keras.layers.Dense(8, activation="relu")
        self.dropout = keras.layers.Dropout(0.5)
        self.output_layer = keras.layers.Dense(1)

    def call(self, inputs, training=False):
        hidden = self.hidden(inputs)
        hidden = self.dropout(hidden, training=training)
        return self.output_layer(hidden)

model = SmallNetwork()
features = tf.ones([3, 2])
print(model(features, training=False).shape)
print(model(features, training=True).shape)
```

Both outputs have the same shape, but the training output can vary because dropout samples a mask. Explicitly forwarding the mode argument avoids custom models that accidentally keep stochastic training behavior active during evaluation or silently disable it during training.

A change in validation loss after switching modes is not always overfitting. Inspect whether validation accidentally used training behavior, whether batch-normalization statistics are well estimated, and whether preprocessing differs. A mode bug can imitate a statistical failure.

## 4. Write a complete custom loop with explicit reductions

The following program uses a regression objective, regularization, a persistent optimizer, and correctly weighted epoch metrics. It is intentionally eager first, making intermediate values easy to inspect.

```python
import tensorflow as tf
from tensorflow import keras

keras.utils.set_random_seed(15)
features = tf.random.normal([65, 2])
targets = 2.0 * features[:, :1] - features[:, 1:2] + 0.5
training = tf.data.Dataset.from_tensor_slices((features, targets))
training = training.shuffle(65, seed=15).batch(16)
model = keras.Sequential([
    keras.Input(shape=(2,)),
    keras.layers.Dense(8, activation="relu", kernel_regularizer=keras.regularizers.L2(1e-4)),
    keras.layers.Dense(1),
])
optimizer = keras.optimizers.Adam(0.01)
epoch_mse = keras.metrics.Mean(name="mse")

for epoch in range(20):
    epoch_mse.reset_state()
    for batch_features, batch_targets in training:
        with tf.GradientTape() as tape:
            predictions = model(batch_features, training=True)
            per_example = tf.reduce_mean(tf.square(predictions - batch_targets), axis=-1)
            data_loss = tf.reduce_mean(per_example)
            regularization = tf.add_n(model.losses) if model.losses else tf.constant(0.0)
            objective = data_loss + regularization
        variables = model.trainable_variables
        gradients = tape.gradient(objective, variables)
        if any(gradient is None for gradient in gradients):
            raise RuntimeError("Unexpected disconnected trainable variable")
        optimizer.apply_gradients(zip(gradients, variables))
        epoch_mse.update_state(per_example)
    if epoch % 5 == 0:
        print(epoch, float(epoch_mse.result().numpy()))
```

There are 65 examples, so the final batch has one example. Updating the mean metric with all per-example values gives each example equal influence across the epoch. Updating with each batch mean without a corresponding weight would overemphasize that final singleton.

The optimized objective includes regularization; the reported MSE excludes it. That separation is deliberate. If you want to report the total objective, define its aggregation carefully and label it accordingly. The optimizer receives gradients of one scalar whose meaning is already established.

This loop does not include validation, early stopping, checkpoint recovery, or distribution. Those features can be added, but writing a custom loop means owning them. Prefer the standard Keras lifecycle when a custom mathematical objective can fit inside a custom layer, loss, or `train_step` without replacing the entire loop.

## 5. Customizing train_step preserves more of fit

A custom `train_step` can retain callbacks, epoch handling, and dataset integration while changing each batch update. The model needs explicit metric objects and a `metrics` property so Keras knows what to reset.

A minimal complete demonstration is:

```python
import tensorflow as tf
from tensorflow import keras

class Regressor(keras.Model):
    def __init__(self):
        super().__init__()
        self.hidden = keras.layers.Dense(8, activation="relu")
        self.head = keras.layers.Dense(1)
        self.mse_tracker = keras.metrics.Mean(name="mse")

    @property
    def metrics(self):
        return [self.mse_tracker]

    def call(self, inputs, training=False):
        return self.head(self.hidden(inputs))

    def train_step(self, data):
        features, targets = data
        with tf.GradientTape() as tape:
            predictions = self(features, training=True)
            per_example = tf.reduce_mean(tf.square(predictions - targets), axis=-1)
            objective = tf.reduce_mean(per_example)
        gradients = tape.gradient(objective, self.trainable_variables)
        self.optimizer.apply_gradients(zip(gradients, self.trainable_variables))
        self.mse_tracker.update_state(per_example)
        return {"mse": self.mse_tracker.result()}

    def test_step(self, data):
        features, targets = data
        predictions = self(features, training=False)
        per_example = tf.reduce_mean(tf.square(predictions - targets), axis=-1)
        self.mse_tracker.update_state(per_example)
        return {"mse": self.mse_tracker.result()}

features = tf.random.normal([32, 2])
targets = tf.reduce_sum(features, axis=-1, keepdims=True)
model = Regressor()
model.compile(optimizer=keras.optimizers.Adam(0.01), jit_compile=False)
model.fit(features, targets, batch_size=8, epochs=2, verbose=0)
print(model.evaluate(features, targets, verbose=0, return_dict=True))
```

This deliberately narrow implementation expects exactly a feature-target pair. It does not support sample weights or attached regularization losses. Production extensions should use explicit unpacking and include those terms correctly. Labeling this boundary is better than presenting a small educational implementation as a universal replacement for Keras training.

We define `test_step` because validation must measure the same intended quantity with inference behavior. A custom training path paired with an unrelated default evaluation path can create confusing reports. Keep training and evaluation contracts aligned even when their update behavior differs.

## 6. Eager execution and graphs are complementary

In eager execution, TensorFlow operations run as Python reaches them. This makes debugging natural: inspect values, print shapes, and use ordinary control flow around concrete results. A graph represents a TensorFlow computation so it can be executed without re-running all its Python construction logic.

`tf.function` traces a Python function to create one or more specialized graph computations. Tracing executes Python code to discover TensorFlow operations for a particular input signature or specialization. Later calls can reuse the graph. It is useful to distinguish tracing time from graph execution time.

```python
import tensorflow as tf

@tf.function(input_signature=[tf.TensorSpec([None, 2], tf.float32)])
def squared_norm(features):
    print("Tracing graph")
    tf.print("Executing batch size", tf.shape(features)[0])
    return tf.reduce_sum(tf.square(features), axis=-1)

print(squared_norm(tf.ones([3, 2])).numpy())
print(squared_norm(tf.ones([5, 2])).numpy())
```

The ordinary Python print runs during tracing, while `tf.print` is a graph operation that runs on execution. The signature permits varying batch size but fixes feature count and dtype. Both calls can share the same traced computation under that signature.

A graph is not an old-style session requirement returning to your everyday code. You still call the function as a Python callable and receive tensors. The graph machinery is encapsulated inside that callable. This preserves much of TensorFlow 2's ergonomic model while enabling optimizations and export.

## 7. Retracing and Python side effects

A `tf.function` may create new traces for different input shapes, dtypes, or Python argument values. Excessive retracing can waste time and memory. Passing a Python counter that changes every call can force specializations when a tensor counter would express the intended runtime value.

Do not assume Python list appends, global assignments, or ordinary prints execute on every graph invocation. They belong to tracing behavior unless represented by appropriate TensorFlow operations. Use `tf.Variable.assign_add` for runtime mutable state and `tf.TensorArray` when graph control flow must accumulate tensors.

Python iterators can also capture the wrong semantics. Consuming a Python iterator while tracing may bake one value into the graph rather than advance it on each execution. Prefer iterating TensorFlow datasets in supported execution paths, or pass the next batch explicitly as a tensor argument.

AutoGraph can convert some Python control flow into TensorFlow control flow when source code is accessible. That does not mean arbitrary Python becomes graph-safe. A condition based on a tensor differs from a condition based on a Python boolean known during tracing. Keep custom graph code simple and test multiple branches.

Variables should normally be created outside a repeatedly called function. Creating fresh variables during tracing or on later calls violates the stable-state model expected by `tf.function`. Build the model and optimizer state deliberately before performance-sensitive graph execution where practical.

## 8. Compile a training step after it works eagerly

The safe progression is a correct eager step, numerical inspection, then graph wrapping. Decorating a broken training step makes debugging harder without changing its mathematical correctness.

The standalone `examples/custom_loop.py` follows this progression with a small regression model. Its compiled step receives batch tensors and returns per-example losses. Epoch control and reporting remain in Python. This creates a clear boundary: TensorFlow owns the repeated numerical kernel, while Python owns experiment organization.

XLA is a further compiler optimization, often requested through `jit_compile=True`. It can fuse and optimize supported operations, but unsupported operations or dynamic behaviors can fail compilation. A graph can execute successfully without XLA. Treat XLA as a benchmarked optimization with a compatibility boundary, not a correctness requirement.

Warmup matters. The first call may include model building, tracing, optimizer variable creation, or compilation. Benchmark steady-state calls separately from cold-start latency. Both quantities can matter: training emphasizes repeated steps, while a rarely used service may be dominated by cold starts.

When timing accelerator work, ensure the measured result has actually completed. Reading a result to the host can synchronize pending work. An apparently tiny Python call duration may otherwise measure dispatch rather than the full device operation. Use supported profiling tools for serious performance claims.

## 9. Debugging a graph should preserve a small reproducer

Temporarily use `run_eagerly=True` in Keras compile to inspect a custom training step more directly. For `tf.function` behavior, `tf.config.run_functions_eagerly(True)` can help isolate graph-related problems, though it does not make every `tf.data` transformation execute as ordinary Python.

Keep assertions in the numerical path. `tf.debugging.assert_all_finite` catches invalid activations or losses close to their origin. Shape assertions document expected ranks and dimensions. If a graph error points to a generated function, reduce the input and extract the smallest problematic operation.

A useful reproducer includes exact shapes, dtypes, a fixed small input, and the version output. Remove the full data loader when a constant tensor reproduces the failure. Conversely, if constants work and real data fails, inspect parsing, raggedness, missing values, and schema drift.

Do not permanently turn off graph execution as the only response to an unexplained discrepancy. First identify whether the computation relied on Python side effects, retraced with unexpected values, or captured stale external state. Then choose an execution mode based on known tradeoffs.

## 10. Profiling identifies the actual bottleneck

Training time may be spent reading data, preprocessing, transferring tensors, executing kernels, synchronizing devices, or writing logs. The fastest optimization depends on which component dominates. A more powerful GPU cannot fix a serial Python decoder that starves it of data.

TensorBoard provides scalar logging and profiling integrations. For a standard Keras run, a callback can record logs:

```python
from tensorflow import keras

callback = keras.callbacks.TensorBoard(
    log_dir="runs/baseline", histogram_freq=0,
)
# Integration fragment: pass callbacks=[callback] to an existing model.fit call.
```

Start TensorBoard with `tensorboard --logdir runs` in the same environment. Profiling support and installation details vary by TensorFlow build and platform. Record the environment and inspect a bounded set of representative steps rather than capturing huge traces indiscriminately.

Look for idle device time, expensive small kernels, repeated host transfers, retracing, and input stalls. Change one important factor at a time, then compare end-to-end throughput and model quality. An optimization that changes data order or precision may also change results, so validate both speed and behavior.

Memory is a separate constraint. Larger batches, longer sequences, retained gradient tapes, and cached datasets all consume memory. An out-of-memory failure can arise from cumulative state retention rather than a single oversized tensor. Check whether Python containers keep references to per-step tensors unnecessarily.

## 11. Mixed precision requires numerical care

Mixed precision uses lower-precision computation for suitable operations while retaining higher precision for sensitive state or outputs. On appropriate hardware, this can improve throughput and reduce activation memory. On other hardware or tiny models, conversion overhead can outweigh any benefit.

```python
import tensorflow as tf
from tensorflow import keras

keras.mixed_precision.set_global_policy("mixed_float16")
model = keras.Sequential([
    keras.Input(shape=(8,)),
    keras.layers.Dense(16, activation="relu"),
    keras.layers.Dense(3, dtype="float32"),
])
model.compile(
    optimizer=keras.optimizers.Adam(),
    loss=keras.losses.SparseCategoricalCrossentropy(from_logits=True),
    jit_compile=False,
)
print(model(tf.ones([2, 8])).dtype)
keras.mixed_precision.set_global_policy("float32")
```

The final logits use float32 to keep loss-facing output precision explicit. Resetting the global policy affects subsequently created layers; it does not retroactively rewrite existing ones. Set the policy before building the model you intend to benchmark.

Float16 gradients can underflow, so loss scaling is often required. Keras's standard compile path supports automatic handling for common mixed-float16 configurations. A fully custom loop needs deliberate use of the appropriate loss-scale optimizer API for its installed version. Do not copy legacy `get_scaled_loss` methods into a Keras 3 loop without checking the current contract.

Bfloat16 has a different exponent and precision tradeoff and is commonly useful on supporting hardware. The right policy depends on the device. Compare a short deterministic float32 baseline before accepting a mixed-precision run, and inspect non-finite values and quality differences.

## 12. Data parallelism and global loss scale

Data parallel training gives several replicas different examples, computes local gradients, and combines their contributions into one update. The conceptual objective should still be the intended mean over the global batch. A replica is not supposed to optimize an independently scaled objective merely because the device count changed.

If there are `R` replicas with equal local batch size `b`, global batch size is `R × b`. In a custom distributed loop, computing a local mean and then summing replica gradients multiplies the intended mean gradient by `R`. A standard pattern uses per-example losses scaled by global batch size, with an explicit reduction across replicas.

For a standard Keras model, a distribution strategy handles much of the machinery:

```python
import tensorflow as tf
from tensorflow import keras

strategy = tf.distribute.MirroredStrategy()
with strategy.scope():
    model = keras.Sequential([
        keras.Input(shape=(2,)),
        keras.layers.Dense(8, activation="relu"),
        keras.layers.Dense(1),
    ])
    model.compile(
        optimizer=keras.optimizers.Adam(0.001),
        loss=keras.losses.BinaryCrossentropy(from_logits=True),
        metrics=[keras.metrics.BinaryAccuracy(threshold=0.0)],
        jit_compile=False,
    )
print("Replicas:", strategy.num_replicas_in_sync)
```

On a CPU-only machine this does not demonstrate multi-GPU speedup. The code shows the scope in which distributed state should be created. Multiworker setups additionally require cluster configuration, input sharding, consistent worker participation, and failure handling.

Increasing global batch size changes update count and optimization dynamics. Linear learning-rate scaling is a heuristic with limits, not a mathematical requirement. Compare training budgets fairly and include communication overhead when measuring speedup.

## 13. Saving for training and exporting for inference

A Keras `.keras` file stores a model in a format intended for Keras loading. A TensorFlow SavedModel export represents an executable inference artifact with signatures and tracked state. These formats serve different use cases.

```python
import tensorflow as tf
from tensorflow import keras

model = keras.Sequential([
    keras.Input(shape=(2,), name="features"),
    keras.layers.Dense(4, activation="relu"),
    keras.layers.Dense(1),
])
probe = tf.constant([[1.0, 2.0]])
expected = model(probe, training=False)
model.save("example.keras")
restored = keras.models.load_model("example.keras")
actual = restored(probe, training=False)
tf.debugging.assert_near(expected, actual)

model.export("inference_savedmodel")
loaded_export = tf.saved_model.load("inference_savedmodel")
exported = loaded_export.serve(probe)
tf.debugging.assert_near(expected, exported)
```

Use `keras.models.load_model` for `.keras` artifacts. Under Keras 3, do not expect it to load an arbitrary SavedModel directory. Use TensorFlow loading for exported signatures or a suitable `TFSMLayer` with the correct endpoint when integrating an inference artifact into another Keras model.

The example's parity check verifies one probe batch, not every possible input. A stronger regression suite includes several representative shapes and edge cases. Preserve tolerances appropriate to the numerical precision and export target.

Custom layers need their registration definitions available when reconstructing a Keras object. Inference exports can encapsulate executable graph behavior without requiring the same Python class reconstruction path, but supported operations and runtime versions still matter. Test in a fresh process resembling the actual consumer.

## 14. Checkpoints preserve recoverable training state

A training checkpoint can track a model and optimizer together:

```python
import tensorflow as tf
from tensorflow import keras

model = keras.Sequential([keras.Input(shape=(2,)), keras.layers.Dense(1)])
optimizer = keras.optimizers.Adam(0.01)
optimizer.build(model.trainable_variables)
checkpoint = tf.train.Checkpoint(model=model, optimizer=optimizer)
manager = tf.train.CheckpointManager(checkpoint, "training_checkpoints", max_to_keep=3)
path = manager.save()
status = checkpoint.restore(path)
status.assert_existing_objects_matched()
```

Building optimizer state makes its current variables explicit for this demonstration. Some restore workflows defer assignments until variables are created. Read restoration status rather than assuming a successful API call means every intended object matched.

A checkpoint still does not necessarily capture the entire experiment. Dataset iterator position, external random generators, scheduler state, data version, and application-specific counters may require additional handling. Define recovery expectations: restarting from the beginning of an epoch is different from bit-for-bit continuation at the next batch.

Keep an inference artifact separate from recovery checkpoints when their lifecycles differ. A serving artifact should not require a training data loader or optimizer. A recovery artifact should contain enough state to resume the chosen procedure, not just return approximately similar predictions.

## 15. Serving begins with an explicit input-output contract

A serving boundary should document feature names, order, shape, dtype, units, missing-value behavior, output interpretation, and version. A tensor with the correct width can still contain the wrong features. Validate semantic constraints before invoking the model.

For binary classification, decide whether the public output is a logit, probability, class, or several of these. If a threshold is part of the service, version it with the model and explain how it was selected. A probability is more flexible for downstream users but also requires a clear calibration and interpretation story.

A small exported module can make the signature explicit:

```python
import tensorflow as tf
from tensorflow import keras

model = keras.Sequential([keras.Input(shape=(2,)), keras.layers.Dense(1)])

class Predictor(tf.Module):
    def __init__(self, model):
        super().__init__()
        self.model = model

    @tf.function(input_signature=[tf.TensorSpec([None, 2], tf.float32, name="features")])
    def predict(self, features):
        tf.debugging.assert_all_finite(features, "Non-finite input")
        logits = self.model(features, training=False)
        return {"probability": tf.math.sigmoid(logits)}

predictor = Predictor(model)
tf.saved_model.save(
    predictor, "explicit_export",
    signatures={"serving_default": predictor.predict},
)
loaded = tf.saved_model.load("explicit_export")
print(loaded.signatures["serving_default"](features=tf.ones([2, 2])))
```

This demonstrates a signature, not a network-accessible service. A real service also needs request parsing, authentication where applicable, resource limits, observability, deployment packaging, and lifecycle management. Those are application engineering concerns around the model.

Batching can increase throughput while increasing waiting time. Evaluate latency percentiles under representative concurrency, not just one isolated prediction. Cold-start cost, preprocessing, and serialization can dominate a small model's numerical execution.

## 16. Edge conversion and quantization change the runtime

An inference model may be converted for a smaller runtime such as LiteRT/TensorFlow Lite. Conversion support depends on the operators and target runtime. Successfully exporting a SavedModel does not imply every edge runtime can execute it.

A basic conversion path is:

```python
import tensorflow as tf
from tensorflow import keras

model = keras.Sequential([keras.Input(shape=(2,)), keras.layers.Dense(1)])
model(tf.zeros([1, 2]))
converter = tf.lite.TFLiteConverter.from_keras_model(model)
converted = converter.convert()
with open("small_model.tflite", "wb") as output_file:
    output_file.write(converted)
print(len(converted))
```

This creates bytes but does not verify predictions in the target runtime. Run the converted artifact with representative inputs and compare outputs to the original model. Operator support and converter APIs are version-sensitive; consult the current edge documentation when deploying.

Quantization stores or computes some values using lower-precision representations. A simple affine scheme relates real values to integer values through a scale and zero point. Calibration data estimates useful activation ranges for some post-training methods. It should represent expected deployment inputs without borrowing labels or information in a way that contaminates final evaluation.

Quantization can reduce artifact size and improve performance on suitable hardware. It can also change quality, particularly for sensitive layers or unusual input ranges. Quantization-aware training simulates some effects during training but adds complexity. Compare end-to-end accuracy and latency on the actual target device rather than assuming smaller files mean faster useful inference.

## 17. A complete capstone and its review criteria

The included tabular capstone is intentionally small enough to read end to end. It generates a noisy binary task, creates three disjoint partitions, adapts normalization on training data, trains with early stopping, evaluates once on held-out data, saves a `.keras` model, reloads it, and checks numerical parity on a probe batch.

Its value is the complete chain of reasoning, not a spectacular benchmark score. The feature contract is explicit. The logits convention is consistent. The split is reproducible. The saved model includes preprocessing. The test report is machine-readable. These are habits that transfer to larger projects.

Before extending the capstone, verify a baseline run. Then change one meaningful factor: feature noise, hidden width, regularization, optimizer, or threshold. Keep the split fixed when comparing model changes. If you repeatedly tune against validation, obtain a final independent test estimate for the selected procedure.

For a vision extension, replace synthetic feature rows with an image dataset and preserve split identities. For a text extension, add a training-adapted vectorizer and a masked sequence encoder. For a serving extension, export a probability signature and test it in a fresh Python process. Each extension should keep its schema and evaluation purpose explicit.

## 18. Read TensorFlow 1 material critically

The source primer's organization remains useful, but its execution examples include historical APIs. A session once explicitly executed graph operations. Eager TensorFlow now evaluates ordinary operations directly, with `tf.function` available when graph execution is useful.

Variable scopes once provided a mechanism for naming and reusing graph variables. Modern Keras layers and model objects express ownership and reuse directly. Calling the same layer object reuses parameters; constructing another object creates another parameter set.

Initializable dataset iterators once managed graph-era input iteration. Modern eager datasets can be iterated directly, and Keras consumes them through `fit`. Removed namespaces such as `tf.contrib` require current replacements, not just a global import alias.

Training and evaluation do not generally require separate copies of a graph and manual weight synchronization in a normal Keras workflow. The same model object can receive `training=True` or `False`. The input data and mode-dependent behavior change; the tracked parameters remain the same objects.

Use `tf.compat.v1` when maintaining genuinely legacy code with a reason to retain that execution model. Do not begin a new TensorFlow 2 learning project by disabling eager execution merely to copy an old snippet unchanged. Translate the underlying intent first.

## 19. What independent competence now looks like

You can now move from a mathematical objective to a concrete TensorFlow implementation, identify data and shape contracts, select a suitable architecture, build and evaluate a training procedure, diagnose gradient and graph failures, and save a model with a reproducible inference boundary.

This is a complete core curriculum rather than an enumeration of every TensorFlow ecosystem package. Specialized domains such as large-scale distributed language-model training, object detection systems, reinforcement learning, and production model governance each warrant further courses. The foundation here gives you the tools to understand their TensorFlow implementations without treating layers, losses, or export calls as magic.

Further reading: [custom layers](https://keras.io/guides/making_new_layers_and_models_via_subclassing/), [tf.function](https://www.tensorflow.org/guide/function), [distributed training](https://www.tensorflow.org/guide/distributed_training), [mixed precision](https://www.tensorflow.org/guide/mixed_precision), [saving](https://keras.io/guides/serialization_and_saving/), and [SavedModel](https://www.tensorflow.org/guide/saved_model). Consult [the validation report](../VALIDATION.md) for what was actually checked in this environment.

## Extended study — Recovery, scaling, and a maintainable project

### Gradient accumulation must preserve the intended mean

When memory limits batch size, gradient accumulation can combine several microbatches before updating parameters. For a fixed model state, the gradient of a sum is the sum of gradients. This allows small forward-backward computations to contribute to an update resembling a larger batch under suitable conditions.

The conditions matter. Dropout samples can differ, batch normalization sees microbatch statistics, and other stateful layers may update on every forward call. Therefore accumulated microbatches are not universally identical to one large batch, even if the gradient algebra is implemented correctly.

For unequal microbatch sizes, accumulate loss sums or appropriately weighted gradients and divide by the total number of contributing examples. Averaging microbatch means equally overweights smaller microbatches. Clear the accumulators after each optimizer update, including any final partial accumulation group.

Regularization must also be counted consistently. Adding the same full regularization gradient on every microbatch and then summing without normalization can multiply its effect. Write the desired large-batch objective before implementing accumulation. The safest small verification compares accumulated and full-batch gradients on a deterministic model without batch-dependent state.

### Distributed custom losses need explicit scaling

TensorFlow's `tf.nn.compute_average_loss` supports scaling per-example losses using a global batch size. In a distributed custom loop, each replica can contribute its local loss sum divided by the global count. Summing replica gradients then corresponds to the intended global mean when the assumptions and reductions match.

Regularization losses need separate treatment so they are not replicated into an unintended multiplier. `tf.nn.scale_regularization_loss` is designed for a common distributed pattern. Check the exact strategy and reduction path rather than adding local penalties by habit.

Partial batches complicate a fixed global denominator. Decide whether to drop remainders or compute a correct actual count across replicas. Dropping examples can be reasonable for a controlled training loop, but usually should not silently discard evaluation cases. State the choice in experiment metadata.

These concerns are why a standard strategy-aware `fit` workflow is a strong default. A custom distributed loop should begin with a numerical equivalence check against a single-device reference on a tiny deterministic batch. Faster execution is not useful if the objective changes with replica count unexpectedly.

### Separate resumability from reproducibility

Resumability means a run can continue after interruption. Reproducibility means another execution can recreate the intended procedure and comparable results. A checkpoint may support resumability while missing the data snapshot necessary for reproducibility. A detailed configuration may support reproducibility while lacking intermediate state needed for quick recovery.

Store a data identifier, schema version, split definition, source revision, environment record, and model configuration beside checkpoint references. If input data is mutable, a path alone is insufficient: the contents at that path may change. A content hash or immutable dataset version gives stronger identity.

For exact continuation, random generators, iterator position, distributed state, and nondeterministic kernels all become relevant. Do not promise bitwise identity merely because a seed exists. For most applied experiments, carefully documented statistical reproducibility is a more realistic and useful target than universal bitwise equivalence.

### Monitor the input contract after deployment

A model can deteriorate without its code changing. Input distributions can shift, categorical values can expand, sensors can change units, or target relationships can evolve. Monitor schema violations, missing-value rates, feature ranges, latency, error rates, and available delayed performance signals.

Data drift means the input distribution changed. Concept drift means the relationship between inputs and targets changed. A changed input histogram does not prove prediction quality fell, and unchanged input histograms do not prove the target relationship stayed stable. Use monitoring signals to trigger investigation rather than automatically drawing conclusions.

Labels may arrive late. A service can monitor immediate technical health while separately tracking eventual prediction quality when outcomes become available. Keep model versions attached to predictions so delayed labels can be joined to the correct producing model.

Avoid logging raw sensitive inputs by default. Operational diagnostics often need schema statistics, aggregate distributions, anonymized identifiers, or carefully controlled samples instead. The right observability design balances debugging needs with the application's data handling requirements.

### Rollback requires compatible artifacts

Retain a previously validated artifact and its associated preprocessing and decision configuration. A rollback that restores weights but keeps a new incompatible vocabulary or feature order can be worse than the failed release. Version the complete inference contract together.

Shadow evaluation can compare a candidate model's outputs without letting it make live decisions. A staged rollout can limit exposure while monitoring behavior. These are deployment patterns to choose according to the application, not actions performed by this curriculum.

Define acceptance criteria before release: representative prediction parity, expected input handling, latency budget, artifact load time, and a quality threshold on a held-out evaluation. Record which failures should stop rollout. A model that loads successfully has passed only one small part of deployment validation.

### Keep project structure aligned with responsibilities

A maintainable training project often separates schema and configuration, data construction, model construction, training, evaluation, and export. This is a responsibility split, not a demand for many tiny files. A small script can remain readable until duplication or independent testing justifies extraction.

Avoid importing a module that starts training as a side effect. Put executable entry points under `if __name__ == "__main__":` so model definitions can be imported by tests or serving code without launching a run. Keep file paths and hyperparameters in explicit configuration rather than hidden globals.

Continuous integration can run syntax checks, small shape and loss-contract tests, serialization parity, and an inexpensive synthetic training smoke test in an environment with TensorFlow installed. Large benchmark runs belong in a separate controlled workflow. Tests should catch meaningful contract failures rather than merely mirror each implementation line.

The course's validation script checks the educational package itself. Its checks do not substitute for application-level model validation. When porting to GitHub, preserve the lesson files, examples, requirements, and source notes together so a future reader can distinguish mathematical derivations, API references, and execution evidence.

### Custom activations and the modern update counter

A custom activation built from differentiable TensorFlow operations usually needs no custom derivative. For example, a smooth gated activation multiplies its input by a sigmoid of that input:

```python
import tensorflow as tf
from tensorflow import keras

@keras.utils.register_keras_serializable(package="Course")
def smooth_gate(inputs):
    return inputs * tf.math.sigmoid(inputs)

model = keras.Sequential([
    keras.Input(shape=(2,)),
    keras.layers.Dense(4, activation=smooth_gate),
    keras.layers.Dense(1),
])
optimizer = keras.optimizers.SGD(0.01)
features = tf.ones([3, 2])
with tf.GradientTape() as tape:
    objective = tf.reduce_mean(tf.square(model(features)))
gradients = tape.gradient(objective, model.trainable_variables)
optimizer.apply_gradients(zip(gradients, model.trainable_variables))
print(int(optimizer.iterations.numpy()))  # 1
```

Automatic differentiation applies the product and chain rules through the activation. Registering the function supports Keras serialization when its defining module is imported. A hand-written custom gradient is appropriate only when there is a concrete mathematical or implementation reason to replace the derivative path.

The optimizer's `iterations` variable is a useful modern update counter. It increases on optimizer updates, not necessarily on every microbatch or forward call. Use that distinction when writing learning-rate schedules, summaries, and checkpoint metadata. The source primer's `global_step` concern survives as update accounting even though the surrounding API has changed.
