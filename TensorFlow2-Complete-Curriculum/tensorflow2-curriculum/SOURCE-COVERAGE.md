# Mapping the source primer to the course

Source: [Aman's AI Journal — TensorFlow primer](https://aman.ai/primers/tensorflow/), reviewed November 12, 2026. This mapping preserves topic intent while replacing historical APIs. The course expands the mathematical and neural network context substantially beyond the primer.

| Primer topic | Course coverage | TensorFlow 2 interpretation |
| --- | --- | --- |
| Environment and GPU setup | Chapter 1, sections 1–2 | Virtual environment, CPU baseline, official platform-specific install guide |
| Code structure | Chapter 5, extended study | Separate data/model/train/evaluate/export responsibilities |
| Graph, session, nodes | Chapter 5, sections 6–9 and 18 | Eager execution plus traced functions; no session required for the baseline |
| Variable scopes and reuse | Chapters 1 and 5 | Tracked layer objects, add_weight, shared object identity |
| Training/evaluation graphs | Chapter 5, sections 3 and 18 | Same parameters with explicit training mode |
| Dataset overview and iterators | Chapter 3, sections 7–9 | Direct dataset iteration and Keras consumption |
| Image reading and augmentation | Chapter 3, sections 10–11 | tf.io decoding, shape contracts, training-only augmentation |
| Text files and zip | Chapter 3, sections 12–13 | Alignment checks, cardinality cautions, paired elements |
| Vocabulary and unknown words | Chapter 3, sections 12–14 | TextVectorization and tf.lookup tables |
| Padding and sentence lengths | Chapters 3–4 | Padded batches, validity masks, real-token denominator |
| Character extraction | Chapter 3, section 14 | Unicode-aware splitting and nested length reasoning |
| Shuffle/repeat/map/prefetch/order | Chapter 3, sections 8 and 16 | Explicit stream semantics, finite epochs, cache placement |
| Model definition and training operations | Chapters 1–3 and 5 | Layers, GradientTape, optimizers, fit, custom steps |
| Evaluation and stateful metrics | Chapters 2–3 and 5 | Separate loss/metric/decision; lifecycle and weighted aggregation |
| Initialization | Chapters 1–2 | Symmetry breaking, scale, tracked variables |
| Saving | Chapter 5, sections 13–15 | Keras files, checkpoints, SavedModel signatures and parity |
| TensorBoard | Chapter 5, section 10 | Callback logging and evidence-based profiling |
| Custom activation | Chapter 5, final extended section | Registered differentiable function |
| Model summary | Chapter 1, section 12 | Parameter counting and model.summary |
| Global step | Chapter 2 schedules and Chapter 5 final section | Optimizer iterations and explicit update accounting |

Additional curriculum coverage includes matrix geometry, probability-based objectives, dense-layer backpropagation, validation design, structured inputs, TFRecord, convolution, recurrence, attention, transformers, autoregressive generation, reconstruction, a small variational objective, mixed precision, distribution scaling, serving contracts, and recovery.
