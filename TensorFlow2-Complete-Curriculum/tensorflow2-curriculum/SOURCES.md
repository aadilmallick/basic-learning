# Sources, versions, and interpretation

Research date: **November 12, 2026**. URLs below are direct source links for readers and remain version-sensitive. Original calculations, derivations, synthetic examples, and engineering explanations are written for this curriculum rather than reproduced from the source pages.

## Supplied curriculum source

[Aman's AI Journal — TensorFlow primer](https://aman.ai/primers/tensorflow/) establishes the starting coverage: environment, graph concepts, input pipelines for images and text, training, evaluation, initialization, saving, TensorBoard, custom activations, summaries, and step tracking. Its examples include TensorFlow 1 APIs. The course translates their intent rather than recommending those historical snippets unchanged. [The coverage map](SOURCE-COVERAGE.md) records the translation.

## Official references consulted for compatibility and APIs

| Reference | Relevant contract or topic | Course location |
| --- | --- | --- |
| [TensorFlow installation](https://www.tensorflow.org/install/pip) | Package installation and platform/GPU constraints | 1 |
| [TensorFlow basics](https://www.tensorflow.org/guide/basics) | Eager numerical computation and tracked state | 1–2 |
| [Automatic differentiation](https://www.tensorflow.org/guide/autodiff) | Tape recording, watched sources, missing derivative paths | 2 |
| [Keras 3 migration](https://keras.io/guides/migrating_to_keras_3/) | Modern default Keras, symbolic restrictions, format changes | 1, 3, 5 |
| [Functional API](https://keras.io/guides/functional_api/) | Model composition and structured inputs | 3 |
| [Built-in training and evaluation](https://keras.io/guides/training_with_built_in_methods/) | fit/evaluate lifecycle and dataset contracts | 3 |
| [tf.data guide](https://www.tensorflow.org/guide/data) | Dataset construction and transformations | 3 |
| [tf.data performance](https://www.tensorflow.org/guide/data_performance) | Overlap, parallel mapping, caching considerations | 3, 5 |
| [Transfer learning](https://keras.io/guides/transfer_learning/) | Freeze/fine-tune behavior and batch normalization mode | 4 |
| [MultiHeadAttention](https://keras.io/api/layers/attention_layers/multi_head_attention/) | Head dimensions, mask polarity and shape | 4 |
| [Custom layers and models](https://keras.io/guides/making_new_layers_and_models_via_subclassing/) | Weight ownership, build/call/config responsibilities | 5 |
| [Custom TensorFlow training loop](https://keras.io/guides/writing_a_custom_training_loop_in_tensorflow/) | Tape-based updates and custom-loop responsibilities | 2, 5 |
| [tf.function guide](https://www.tensorflow.org/guide/function) | Tracing, runtime execution, Python side effects | 5 |
| [Mixed precision](https://www.tensorflow.org/guide/mixed_precision) | Policy choice and numerical considerations | 5 |
| [Distributed training](https://www.tensorflow.org/guide/distributed_training) | Strategy abstraction and replicated training | 5 |
| [Keras saving](https://keras.io/guides/serialization_and_saving/) | Keras model persistence and custom objects | 5 |
| [SavedModel](https://www.tensorflow.org/guide/saved_model) | Executable signatures and tracked state | 5 |

## Additional learning links

These are follow-up reading paths, not claims that every linked tutorial was executed or audited during creation:

- [Keras losses](https://keras.io/api/losses/) and [optimizers](https://keras.io/api/optimizers/).
- [Keras examples](https://keras.io/examples/) for expanded task-specific implementations, including generative examples.
- [TensorFlow tensors](https://www.tensorflow.org/guide/tensor) and [variables](https://www.tensorflow.org/guide/variable).
- [Convolution layers](https://keras.io/api/layers/convolution_layers/) and [recurrent layers](https://keras.io/api/layers/recurrent_layers/).
- [Google AI Edge LiteRT](https://ai.google.dev/edge/litert) for current target-runtime conversion and deployment guidance.

## Version decisions and limits

The selected learning baseline is **Python 3.11 / TensorFlow 2.20.0 / TensorFlow-backed Keras 3**. This is a deliberately pinned TensorFlow reference, not a latest-version claim. Keras and other transitive dependencies resolve during installation; record their actual versions in a lock file after installing successfully on your platform.

The course consistently uses `from tensorflow import keras`. It does not enable legacy Keras with environment variables or mix `tf_keras` with Keras 3. Historical `tf.Session`, `tf.contrib`, `tf.layers`, iterator initialization, and `tensorflow-gpu` installation snippets are not the baseline workflow.

A SavedModel export and a reloadable Keras file have distinct roles. Fresh-process reload of custom Keras classes needs their registration definitions available. Target-runtime conversion, GPU setup, mixed precision, and distributed execution require version- and hardware-specific validation.

TensorFlow was not installed in the authoring environment. The examples were syntax checked, not TensorFlow executed. Mathematical checks were run independently with NumPy, and all limitations are recorded in [VALIDATION.md](VALIDATION.md). No external datasets, pretrained weights, training results, latency measurements, or GPU benchmarks are claimed.
