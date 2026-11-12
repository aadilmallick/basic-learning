# Lesson 3 — Keras, data pipelines, and trustworthy experiments

[Previous lesson](02-autodiff-losses-and-optimization.md) · [Course index](../README.md) · [Next lesson](04-vision-sequences-attention-and-generative-models.md)

## 1. The model is only one part of the experiment

A correct gradient calculation does not guarantee a useful machine learning system. We can train on mislabeled examples, evaluate on leaked data, normalize with future information, or report a metric that hides the failures users care about. This chapter builds the organizational layer around the mathematics.

We will use Keras to express models and `tf.data` to express streams of examples. Think of a dataset as a recipe for producing elements, not necessarily as a fully materialized array. Think of a Keras model as a tracked composition of layers with convenient training, evaluation, and saving interfaces. Neither abstraction changes what a loss or gradient means.

The recurring example is binary classification from two numerical features. Synthetic data keeps execution small and removes the need to download a dataset. Image and text pipelines then show how the same contracts extend to more complex inputs. Where a code block needs local files, the block creates those files or explicitly identifies itself as an integration fragment.

## 2. Split before fitting any learned preprocessing

A training partition selects parameters. A validation partition supports choices such as architecture, learning rate, early stopping, and decision threshold. A test partition estimates performance after those choices are settled. Repeatedly consulting test results makes the test set part of the development process, weakening its role as an independent estimate.

Random splitting is appropriate when examples are sufficiently exchangeable for the deployment question. It is inappropriate when several rows belong to the same person and deployment concerns new people. A group split keeps a person's rows together. Forecasting usually requires a time split that trains on the past and evaluates on later observations.

Leakage is broader than copying target values into features. It includes duplicated images across partitions, a vocabulary adapted using test documents, normalizers fitted on all rows, or a feature recorded only after the event being predicted. The correct split depends on the information available at prediction time.

```python
import numpy as np

rng = np.random.default_rng(21)
features = rng.normal(size=(900, 2)).astype("float32")
labels = (features[:, 0] + 0.7 * features[:, 1] > 0).astype("float32")[:, None]
order = rng.permutation(len(features))
train_ids, validation_ids, test_ids = order[:600], order[600:750], order[750:]
x_train, y_train = features[train_ids], labels[train_ids]
x_validation, y_validation = features[validation_ids], labels[validation_ids]
x_test, y_test = features[test_ids], labels[test_ids]
```

The labels are a deterministic rule, so this toy task has no irreducible label noise. A real application may be much harder even with the same input dimension. The random permutation is reproducible because the generator has a fixed seed. We keep explicit arrays for each partition so later transformations cannot accidentally mix them.

A good experiment also has a baseline. For classification, compare against a majority-class predictor and a simple linear model. For forecasting, compare against a last-value or seasonal baseline. If a complex neural network cannot beat a well-chosen simple method, complexity has not earned its cost.

## 3. Sequential and Functional models represent different structures

A straight chain is naturally expressed with `Sequential`. Multiple inputs, shared layers, skip connections, or multiple outputs are more naturally expressed with the Functional API. A subclassed model gives the most Python flexibility but requires more care around build behavior, configuration, and export.

```python
import tensorflow as tf
from tensorflow import keras

model = keras.Sequential([
    keras.Input(shape=(2,), name="features"),
    keras.layers.Dense(16, activation="relu"),
    keras.layers.Dense(1, name="logit"),
])
print(model(tf.zeros([3, 2])).shape)  # (3, 1)
```

The last layer produces logits, so its activation is intentionally omitted. A hidden ReLU lets this model represent nonlinear boundaries, although the toy data rule itself is linear. Starting with a small model is useful because unnecessary capacity can obscure whether preprocessing and evaluation are correct.

The same basic architecture in the Functional API is:

```python
from tensorflow import keras

inputs = keras.Input(shape=(2,), name="features")
hidden = keras.layers.Dense(16, activation="relu")(inputs)
logits = keras.layers.Dense(1, name="logit")(hidden)
model = keras.Model(inputs=inputs, outputs=logits)
```

Calling a layer on an input symbol records a relationship used to construct the model. A `KerasTensor` in this construction describes a symbolic computation; it is not an ordinary concrete batch from which you can immediately call `.numpy()`. Use Keras layers or Keras operations when composing this symbolic graph. Place TensorFlow-specific logic inside a custom layer when appropriate.

Sharing a layer object shares its weights. Constructing two separate `Dense` objects with identical arguments creates two separate parameter sets. This distinction matters for Siamese models, shared encoders, and transfer learning. Names do not create parameter sharing; object identity and connectivity do.

## 4. Put learned preprocessing inside the model

A normalizer estimates feature statistics from training data. Keeping that transformation inside the model helps ensure inference uses the same scaling as training.

```python
from tensorflow import keras

# Integration block: x_train is produced by the split example above.
normalizer = keras.layers.Normalization(axis=-1)
normalizer.adapt(x_train)
inputs = keras.Input(shape=(2,), name="features")
hidden = normalizer(inputs)
hidden = keras.layers.Dense(16, activation="relu")(hidden)
logits = keras.layers.Dense(1, name="logit")(hidden)
model = keras.Model(inputs, logits)
```

`adapt` estimates state; it is not ordinary gradient training. Call it on training features only. The normalizer stores its resulting statistics as model state. The model's public input remains raw numerical features rather than secretly requiring a separate caller to remember scaling constants.

Other preprocessing layers can learn vocabularies or handle categorical features. Not every transformation belongs inside the same exported graph: some parsing libraries or external services may be unsuitable for export. When preprocessing remains external, version it and test parity explicitly.

Schema is part of preprocessing. The vector `[temperature, area]` is not interchangeable with `[area, temperature]`, even though both have shape `(2,)`. Document units, order, missing-value conventions, and allowed ranges. A model can produce finite, confident predictions from a semantically reversed feature vector.

## 5. Compile configures a training procedure

Keras `compile` selects the optimizer, loss, and reporting metrics. It does not perform learning by itself.

```python
from tensorflow import keras

# Integration block: model is the model defined in the preceding section.
model.compile(
    optimizer=keras.optimizers.Adam(learning_rate=0.001),
    loss=keras.losses.BinaryCrossentropy(from_logits=True),
    metrics=[keras.metrics.BinaryAccuracy(name="accuracy", threshold=0.0)],
    jit_compile=False,
)
```

The binary accuracy threshold is zero because outputs are logits. Zero logits correspond to probability one half. The loss also declares that it receives logits. This consistent contract prevents an easy error in which training and evaluation interpret the same output differently.

`jit_compile=False` keeps the baseline independent of XLA compatibility. Graph execution through Keras can still occur; XLA compilation is a separate optimization. We will examine these layers of execution in the final chapter rather than treating every form of compilation as the same thing.

A metric object maintains accumulated state. For example, accuracy tracks counts across batches. Its result should represent the evaluation dataset, not just the last batch. Keras manages metric resets in its standard training lifecycle. Custom loops must reset and update state explicitly.

## 6. Fit, validation, callbacks, and inference

For in-memory arrays, the training call is compact:

```python
from tensorflow import keras

# Integration block: model and partition arrays come from earlier sections.
callbacks = [
    keras.callbacks.EarlyStopping(
        monitor="val_loss", patience=8, restore_best_weights=True,
    ),
    keras.callbacks.ModelCheckpoint(
        "best_classifier.keras", monitor="val_loss", save_best_only=True,
    ),
    keras.callbacks.TerminateOnNaN(),
]
history = model.fit(
    x_train, y_train,
    validation_data=(x_validation, y_validation),
    batch_size=32,
    epochs=100,
    callbacks=callbacks,
    verbose=0,
)
print(model.evaluate(x_test, y_test, verbose=0, return_dict=True))
```

An epoch processes the training data; validation then evaluates without parameter updates. Early stopping selects an epoch using validation performance. Restoring the best weights is helpful for inference, but it does not necessarily restore optimizer state corresponding to that epoch. Reload a complete best checkpoint when faithful training continuation matters.

The `history` object stores recorded values per epoch. Interpret curves together. Falling training loss with rising validation loss often indicates overfitting, but mismatched preprocessing or a changing validation distribution can produce similar symptoms. A graph is evidence to investigate, not an automatic diagnosis.

Use `model(batch, training=False)` for a direct small inference call. `model.predict` is convenient for batched prediction workflows. Neither creates valid probabilities from logits automatically; apply sigmoid when probability outputs are required. Keep class decisions separate from raw scores so thresholds remain configurable.

## 7. Dataset elements are the central contract

A `tf.data.Dataset` produces a sequence of elements. An element can be a tensor, a tuple, or a nested dictionary. For ordinary supervised Keras training, an element commonly has structure `(features, targets)` or `(features, targets, sample_weights)`.

```python
import tensorflow as tf

features = tf.constant([[1.0, 2.0], [3.0, 4.0], [5.0, 6.0]])
labels = tf.constant([[0.0], [1.0], [1.0]])
dataset = tf.data.Dataset.from_tensor_slices((features, labels))
print(dataset.element_spec)
for example_features, example_label in dataset:
    print(example_features.numpy(), example_label.numpy())
```

`from_tensor_slices` slices the first axis of each component together. Each element contains one feature row and its corresponding label row. Batching later adds a leading dimension. Inspect `element_spec` to see the shapes and dtypes a pipeline promises before executing a large training job.

Modern TensorFlow datasets are directly iterable in eager execution. The source primer's sessions and initializable iterator examples reflect an older execution model. We retain its emphasis on dataset transformations but replace the obsolete control structure with ordinary iteration and Keras integration.

A dataset is not automatically shuffled. It is not automatically split. It is not automatically finite. Each property depends on how its recipe was constructed. Read pipeline code in transformation order and track both element structure and cardinality.

## 8. Map, shuffle, batch, repeat, and prefetch

Mapping applies a transformation to elements. Shuffling rearranges their order within a buffer. Batching groups consecutive elements. Repeating revisits the input stream. Prefetching overlaps the production of future elements with their consumption.

```python
import tensorflow as tf

values = tf.data.Dataset.range(12)
pipeline = (
    values
    .map(lambda value: tf.cast(value, tf.float32) / 12.0)
    .shuffle(12, seed=5, reshuffle_each_iteration=True)
    .batch(4)
    .prefetch(tf.data.AUTOTUNE)
)
for batch in pipeline:
    print(batch.shape)
```

Three batches of shape `(4,)` are produced. The exact order is randomized. Buffer size twelve allows a full permutation of this twelve-element source; a smaller buffer only mixes a local moving window. For enormous datasets, full shuffling may be too memory-intensive, so practical pipelines use bounded mixing.

Order changes meaning. Shuffling examples before batching mixes examples within batches. Batching first and then shuffling only rearranges whole preexisting groups. Caching before random augmentation preserves fresh randomness on later epochs; caching after augmentation can freeze the initially sampled transformations.

Repeated datasets may be infinite. Passing an infinite dataset to `fit` requires a finite `steps_per_epoch` so an epoch can end. Validation datasets should usually remain finite and deterministic. An infinite validation stream can make evaluation run indefinitely unless explicit step counts are supplied.

Prefetch is not a promise that data loading disappears. It overlaps producer and consumer work when possible. If loading is much slower than model computation, a deeper buffer cannot manufacture missing throughput indefinitely. Profile before claiming an optimization helped.

## 9. Weighted aggregation and the final small batch

Suppose validation produces batch losses `0.2` for 100 examples and `0.8` for ten examples. Averaging those two batch means gives `0.5`, but the per-example mean is `(100 × 0.2 + 10 × 0.8) / 110`, approximately `0.2545`. The smaller last batch must not receive the same weight as a much larger batch when reporting a per-example mean.

In custom evaluation, track loss sums and valid-example counts or update a mean metric with per-example losses. Standard Keras paths handle many common cases, but custom reductions and sample weights still require deliberate interpretation.

A related issue appears in padded sequences. The correct denominator may be number of real tokens, not batch size times maximum padded length. If we average over padding, long and short batches can contribute inconsistently, and a model can appear to improve by seeing more padded positions.

Write the intended scalar statistic first, then implement it. Are we averaging per example, per token, per sequence, or per patient? These can all be defensible metrics, but they answer different questions. A sequence-level average gives each sequence equal influence; a token-level average gives longer sequences more influence.

## 10. Build an image pipeline from real bytes

The following self-contained example creates a small JPEG, then reads it through the same file-oriented path used for larger datasets.

```python
from pathlib import Path
import tensorflow as tf

folder = Path("demo_images")
folder.mkdir(exist_ok=True)
image_path = folder / "sample.jpg"
pixels = tf.ones([12, 10, 3], dtype=tf.uint8) * 127
tf.io.write_file(str(image_path), tf.io.encode_jpeg(pixels))

filenames = tf.constant([str(image_path)])
labels = tf.constant([1], dtype=tf.int32)

def decode_image(filename, label):
    image_bytes = tf.io.read_file(filename)
    image = tf.io.decode_jpeg(image_bytes, channels=3)
    image = tf.image.convert_image_dtype(image, tf.float32)
    image = tf.image.resize(image, [16, 16])
    image = tf.ensure_shape(image, [16, 16, 3])
    return image, label

images = tf.data.Dataset.from_tensor_slices((filenames, labels))
images = images.map(decode_image, num_parallel_calls=tf.data.AUTOTUNE)
images = images.batch(1).prefetch(tf.data.AUTOTUNE)
for batch_images, batch_labels in images:
    print(batch_images.shape, batch_labels.numpy())
```

The decoder turns compressed bytes into a grid of channel values. Conversion from uint8 to float32 scales values to an appropriate unit interval before resizing. Resizing changes the spatial grid. The shape assertion records the expected contract for downstream layers.

Do not divide by 255 twice. A `Rescaling(1/255)` layer expects values in the original zero-to-255 scale; applying it after `convert_image_dtype` would shrink already scaled values again. Choose one preprocessing boundary and document it.

A photograph's channel order also matters. JPEG decoding here produces RGB. A separate computer-vision library might produce BGR. Both have the same shape, so shape validation alone cannot catch the semantic swap. Use a known reference image when integrating a new decoding system.

## 11. Augmentation expresses task assumptions

Augmentation generates modified training inputs that should preserve the target under a task-specific assumption. Horizontal flipping may preserve whether a photograph contains a cat. It may change the meaning of a left-turn road sign or a handwritten character. More augmentation is not automatically better.

Keras augmentation layers can live inside the model and act during training:

```python
from tensorflow import keras

augmentation = keras.Sequential([
    keras.layers.RandomFlip("horizontal"),
    keras.layers.RandomRotation(0.05),
], name="augmentation")
inputs = keras.Input(shape=(16, 16, 3))
augmented = augmentation(inputs)
features = keras.layers.Conv2D(8, 3, activation="relu")(augmented)
features = keras.layers.GlobalAveragePooling2D()(features)
logits = keras.layers.Dense(2)(features)
image_model = keras.Model(inputs, logits)
```

The rotation factor is a fraction of a full turn, not a count of degrees. Always check argument units. The network is illustrative and untrained; its small image size is chosen for inexpensive execution, not as a recommendation for every vision task.

Validation preprocessing should normally be deterministic. Random validation augmentation can add metric noise and make checkpoint selection unstable. Test-time augmentation is a separate deliberate method that combines several inference views; evaluate its cost and accuracy as part of the decision policy.

For segmentation or detection, spatial augmentation must transform targets consistently with images. Flipping an image without flipping its mask or box coordinates corrupts supervision. The general lesson is that data transformations operate on an input-target relationship, not merely on input arrays.

## 12. Text pipelines need vocabularies and length contracts

Text begins as strings. Neural layers typically consume integer IDs or dense embeddings. A vocabulary maps tokens to IDs. A text vectorizer combines standardization, tokenization, vocabulary lookup, and optional length handling.

```python
import tensorflow as tf
from tensorflow import keras

training_text = tf.constant([
    "small models are useful",
    "data quality matters",
    "models learn from data",
])
vectorizer = keras.layers.TextVectorization(
    max_tokens=100,
    output_mode="int",
    output_sequence_length=6,
)
vectorizer.adapt(training_text)
ids = vectorizer(tf.constant(["useful unknownword models"]))
print(vectorizer.get_vocabulary())
print(ids.numpy())
```

In integer mode, zero is reserved for padding and an out-of-vocabulary index handles unfamiliar tokens. The learned word IDs depend on the adapted vocabulary; do not hard-code semantic assumptions about a particular numerical ID. Save the vectorizer with the model or persist its exact vocabulary.

A fixed sequence length pads short inputs and truncates long ones. Truncation can discard important information, so inspect length distributions before choosing a limit. It also bounds memory and latency, especially for attention whose ordinary score matrix grows quadratically with sequence length.

Default word splitting is not a complete modern tokenizer. Subword tokenization can handle morphology and rare words more flexibly. For a pretrained language model, use its exact tokenizer and vocabulary; substituting this simple vectorizer changes what its embedding IDs mean.

## 13. Variable lengths, masks, and paired label files

A sequence tagger assigns one label per input token. Token and label sequences must stay aligned. Zipping two datasets stops at the shorter dataset, so file count mismatches can silently discard examples unless checked. Prefer a record format that stores paired fields together when possible.

The following example creates paired files and pads both components:

```python
from pathlib import Path
import tensorflow as tf

Path("sentences.txt").write_text("John lives here\nMary runs\n", encoding="utf-8")
Path("tags.txt").write_text("1 0 0\n1 0\n", encoding="utf-8")
sentences = tf.data.TextLineDataset("sentences.txt")
tags = tf.data.TextLineDataset("tags.txt")
paired = tf.data.Dataset.zip((sentences, tags))

def parse_pair(sentence, tag_line):
    tokens = tf.strings.split(sentence)
    tag_ids = tf.strings.to_number(tf.strings.split(tag_line), tf.int32)
    tf.debugging.assert_equal(tf.size(tokens), tf.size(tag_ids))
    return tokens, tag_ids

paired = paired.map(parse_pair)
paired = paired.padded_batch(
    2,
    padded_shapes=([None], [None]),
    padding_values=(tf.constant(""), tf.constant(-1, tf.int32)),
)
for tokens, tag_ids in paired:
    print(tokens.numpy())
    print(tag_ids.numpy())
```

The second sentence receives an empty token and label `-1` at the padded position. That sentinel is not a valid class label. Before computing categorical loss, replace sentinel labels with a valid dummy class and use a separate mask to exclude their loss. Passing negative labels into the loss and multiplying afterward is unsafe because the loss may reject them before masking occurs.

Ragged tensors represent rows with differing lengths without filling every row to a common length. Sparse tensors represent a different idea: mostly absent entries in a logical dense structure. Neither representation is universally supported by every layer or export target. Padding is often simpler for a first model, provided masks are handled correctly.

## 14. Lookup tables and character representations

For explicit token lookup, a static vocabulary table is useful when preprocessing must remain TensorFlow-native. Reserve zero for padding and one for unknown tokens, then assign real words from two upward.

```python
import tensorflow as tf

initializer = tf.lookup.KeyValueTensorInitializer(
    keys=tf.constant(["John", "lives", "here"]),
    values=tf.constant([2, 3, 4], dtype=tf.int64),
)
table = tf.lookup.StaticHashTable(initializer, default_value=tf.constant(1, tf.int64))
tokens = tf.strings.split(tf.constant("John visits here"))
print(table.lookup(tokens).numpy())  # [2, 1, 4]
```

A lookup table is state that must travel with the preprocessing implementation. It does not learn word meaning; it assigns identifiers. A later embedding layer learns continuous vectors associated with those identifiers.

Character features can help represent unseen words. `tf.strings.unicode_split` splits Unicode text into code points, which is more appropriate than treating each UTF-8 byte as a character. A code point still does not always correspond to one user-perceived character; combining marks and grapheme clusters complicate that notion.

A character-based word representation introduces nested length dimensions: examples contain tokens, and tokens contain characters. Padding and masking may be needed at both levels. This is an example where drawing the conceptual shape `(batch, words, characters)` before implementation prevents confusion.

The source primer includes character extraction as an advanced pipeline topic. Its central lesson remains useful: representation choices propagate into shapes and masks. Modern code should use current string and lookup APIs rather than the removed `tf.contrib` namespace.

## 15. TFRecord separates storage from parsing

TFRecord is a container format for sequences of byte records. A common payload is a serialized `tf.train.Example`, which stores named typed features. TFRecord itself does not enforce your application schema; parsing code supplies that contract.

```python
import tensorflow as tf

example = tf.train.Example(features=tf.train.Features(feature={
    "features": tf.train.Feature(float_list=tf.train.FloatList(value=[1.0, 2.0])),
    "label": tf.train.Feature(int64_list=tf.train.Int64List(value=[1])),
}))
with tf.io.TFRecordWriter("tiny.tfrecord") as writer:
    writer.write(example.SerializeToString())

schema = {
    "features": tf.io.FixedLenFeature([2], tf.float32),
    "label": tf.io.FixedLenFeature([], tf.int64),
}

def parse_record(serialized):
    values = tf.io.parse_single_example(serialized, schema)
    return values["features"], values["label"]

records = tf.data.TFRecordDataset(["tiny.tfrecord"]).map(parse_record)
for features, label in records:
    print(features.numpy(), label.numpy())
```

The feature specification expects exactly two floats and one integer. If storage changes without a corresponding schema version, parsing can fail or misinterpret values. Record field names, units, and required features in a schema document.

Sharding a large dataset into several files allows parallel reading. Too many tiny files can create overhead; one enormous file can limit parallelism and recovery granularity. The appropriate shard size depends on storage and workload. Benchmark representative access rather than assuming a universal number.

TFRecord does not inherently prevent leakage, guarantee label quality, or make preprocessing faster. It is a storage choice. For a small CSV already loaded into memory, introducing TFRecord can add unnecessary complexity. Choose it when sequential reading, distributed input, or standardized record packaging solves a real problem.

## 16. Performance and correctness must be checked together

Parallel `map` calls can decode several examples concurrently. `AUTOTUNE` allows runtime tuning of some parallelism and buffering choices. `cache` can avoid repeated expensive deterministic work when the cached data fits the intended memory or disk budget.

A practical image order is filenames, optional shuffle, decode and deterministic resize, cache if appropriate, random augmentation, batch, then prefetch. Other orders can be better for particular storage and augmentation strategies. Explain what state is frozen and what work repeats before adopting a recipe.

Determinism settings affect ordering. Parallel transformations may be allowed to produce results out of order for throughput. This is acceptable for many shuffled training streams but problematic when predictions must remain aligned with a separate list of IDs. Keep IDs inside the same dataset element until outputs are recorded.

Avoid `tf.py_function` as a default escape hatch for preprocessing. It invokes Python and can complicate serialization, shape inference, portability, and throughput. It can be useful for an unavoidable prototype integration, but isolate it and document the deployment consequence.

Benchmark enough iterations to get past startup and warmup. Compare end-to-end training time as well as raw pipeline throughput. A faster input iterator does not help if the model already dominates step time. Conversely, a faster model may reveal that data loading has become the bottleneck.

## 17. Evaluate beyond one aggregate score

A confusion matrix counts true and predicted classes. For a binary task, inspect false positives and false negatives separately. Their consequences may differ significantly even if they contribute equally to accuracy.

```python
import tensorflow as tf

true_labels = tf.constant([0, 0, 1, 1, 1])
predicted_labels = tf.constant([0, 1, 1, 0, 1])
print(tf.math.confusion_matrix(true_labels, predicted_labels, num_classes=2).numpy())
```

Rows represent true classes and columns predicted classes. The result is `[[1, 1], [1, 2]]`. A matrix is easier to interpret when accompanied by class names and sample counts. A small subgroup can have an apparently extreme percentage based on very few observations.

Evaluate meaningful slices such as document length, acquisition device, language, or time period when those variables matter to deployment. Slice analysis can uncover systematic failures hidden by an overall mean. It also creates multiple comparisons, so treat tiny noisy differences cautiously rather than declaring every fluctuation a discovery.

Calibration asks whether predicted probabilities correspond to observed event frequencies. A reliability analysis groups predictions by confidence and compares average confidence with observed positive rate or accuracy under the chosen definition. Good ranking does not imply good calibration. Distribution shift can degrade both.

A final test score estimates performance under the test sampling process. It does not prove safety under arbitrary future inputs. State the population, time period, split logic, and uncertainty around the estimate. These details make the number actionable.

## 18. A complete experiment belongs in a script

The downloadable `examples/tabular_capstone.py` combines the core path: seeded synthetic data, an explicit train-validation-test split, a training-only normalizer, a small Keras model, a logits-compatible loss and metric, early stopping, evaluation, saving, and reload parity. It uses no downloaded dataset and is the recommended first end-to-end run after installing dependencies.

Read the program from its data contract outward. Its public feature vector has two entries. Its target is a binary event stored as a column. Its output is a logit until explicitly converted to probability. Every training choice should be understandable in terms of the mathematics from the preceding chapter.

A useful experiment record includes the source revision, environment versions, dataset identity, split seed or group rule, model configuration, optimizer settings, selected checkpoint, and evaluation report. A notebook screenshot alone is insufficient to reconstruct the run. Save machine-readable results where practical.

Keep test evaluation out of an automated hyperparameter search. Search on training and validation data, select a configuration, then evaluate the chosen procedure on the held-out test partition. If the test result triggers another round of changes, acknowledge that the test has now influenced development and obtain a fresh independent estimate when possible.

## 19. Transition to architectural choices

You now have the machinery for a valid small experiment. Architecture can therefore be discussed as a modeling choice rather than a collection of fashionable layer names. The next chapter asks what structure images, sequences, and language contain, and how convolution, recurrence, attention, and generative objectives encode useful assumptions about that structure.

The pipeline remains central throughout. A brilliant architecture with misaligned tokens and labels is still wrong. A modest model with a correct split, meaningful baseline, and repeatable preprocessing is a stronger foundation for improvement.

Further reading: [the Functional API](https://keras.io/guides/functional_api/), [built-in training](https://keras.io/guides/training_with_built_in_methods/), [tf.data](https://www.tensorflow.org/guide/data), and [input performance](https://www.tensorflow.org/guide/data_performance). The course's integration blocks are labeled so they are not mistaken for independent scripts.

## Extended study — Structured inputs, missingness, and experiment design

### Multiple inputs preserve distinct meanings

A customer record might contain numerical features and a text description. Concatenating raw strings and floats is not meaningful, so each input needs its own representation path. The Functional API can combine the resulting numerical features near the prediction head.

```python
import tensorflow as tf
from tensorflow import keras

numeric_input = keras.Input(shape=(3,), name="numeric")
token_input = keras.Input(shape=(5,), dtype="int32", name="tokens")
numeric_features = keras.layers.Dense(8, activation="relu")(numeric_input)
token_vectors = keras.layers.Embedding(50, 8, mask_zero=True)(token_input)
text_features = keras.layers.GlobalAveragePooling1D()(token_vectors)
combined = keras.layers.Concatenate()([numeric_features, text_features])
logits = keras.layers.Dense(1)(combined)
model = keras.Model(
    inputs={"numeric": numeric_input, "tokens": token_input},
    outputs=logits,
)
batch = {
    "numeric": tf.ones([2, 3]),
    "tokens": tf.constant([[2, 3, 0, 0, 0], [4, 5, 6, 0, 0]]),
}
print(model(batch, training=False).shape)
```

The dictionary keys align data with named input branches. The embedding pool uses the supplied mask through a compatible layer. Entirely empty text rows need a deliberate policy because averaging no real tokens is not a meaningful document representation. Filter them, supply an explicit missing-text token, or add a separate missingness feature.

The architecture allows each modality to contribute, but it does not guarantee both will be used. A strong numerical shortcut may cause the text branch to receive little useful learning signal. Evaluate ablations and slices to understand whether the additional modality improves the intended task.

### Missing values are information and an integration problem

A missing numerical value should not be replaced with zero blindly if zero is a legitimate measurement. One simple approach is training-only imputation plus a missingness indicator. The imputed value supplies a finite input; the indicator allows the model to distinguish observed and imputed entries.

Imputation statistics belong to the training partition. For a feature with no observed training values, a median cannot be estimated meaningfully. That feature requires a domain decision, a fallback contract, or removal. Silent numerical replacement can conceal an unusable data source.

Missingness patterns can be predictive because of the collection process. That can help within one workflow and fail when the workflow changes. For example, a test being ordered may correlate with a condition even before its result exists. Whether that feature is permissible depends on prediction time and the actual deployment process.

Unknown categorical values are different from missing ones. A new category may deserve an out-of-vocabulary representation, while missingness may deserve a dedicated token. Combining them can discard useful distinctions. Preserve these policies in the model schema so inference does not invent incompatible IDs.

### Multiple outputs require a weighted objective

A shared encoder can feed several heads, such as a binary risk score and a continuous cost estimate. Each head needs its own output contract, loss, and metrics. The total objective combines the component losses with explicit weights.

A cost loss measured in large squared currency units can overwhelm binary cross-entropy if simply added. Rescaling targets or weighting tasks changes the tradeoff. The weights define what improvement in one task is worth relative to another, so they should be selected for a reason rather than copied from an unrelated project.

Shared parameters receive gradient contributions from all heads. Those contributions can align or conflict. Multitask learning can improve data efficiency when tasks share useful structure, but it can also cause negative transfer. Compare with separate models and inspect each task's validation performance rather than reporting only the total loss.

For partially observed labels, mask unavailable targets without introducing invalid values into the component loss. A missing target should not be treated as a negative class. Track the number of supervised examples contributing to each head so an apparently stable metric is not based on almost no observations.

### Sample weighting changes the population being optimized

Sample weights can represent unequal importance, class balancing, confidence, or correction for a sampling scheme. These meanings are not interchangeable. Multiplying a loss by a class weight encourages attention to that class, but resulting probability outputs may need calibration under the real deployment distribution.

If weights are intended to form a weighted mean, decide whether the denominator is the number of examples or the sum of weights. Some APIs' reduction conventions use the former in particular configurations. A custom objective should write the desired numerator and denominator explicitly rather than infer semantics from a variable named weight.

Weighted metrics also need explicit configuration. In Keras, metrics and weighted metrics have distinct roles. Verify a tiny hand-calculated weighted example before interpreting a production report. A weight array that silently broadcasts across the wrong axis can produce plausible but incorrect results.

### Cross-validation and limited datasets

With little data, a single validation split can be noisy. Cross-validation evaluates a procedure over several training-validation folds. Every fold must refit learned preprocessing using that fold's training data only. Reusing a normalizer adapted on all folds leaks information into the validation portions.

Group and time constraints still apply. Random folds do not solve leakage from repeated people or future observations. For forecasting, an expanding-window evaluation can better mimic repeated deployment from earlier data to later periods. Its folds answer a different question from randomly shuffled folds.

Hyperparameter selection and performance estimation are separate layers. If the same cross-validation results are used repeatedly to choose settings, the best score is optimistically selected. Nested evaluation or an untouched final holdout can provide a stronger estimate of the selected procedure. The appropriate effort depends on data volume and decision stakes.

The practical habit is to write the evaluation question in ordinary language before building partitions. Are we predicting new rows from known users, new users, a later month, or a new institution? The code should implement that question. A split function alone cannot determine which question matters.

### Probability-based reporting needs probability inputs

The zero threshold used for binary accuracy on logits is not a universal metric setting. Metrics that sweep probability thresholds, such as a conventional AUC configuration, should receive probabilities or explicitly declare logits where supported. Feeding untransformed scores into a metric that assumes the interval zero to one can distort the reported result.

Keep a clear evaluation boundary: obtain logits from the model, apply sigmoid once, then update probability-based reporting with those values. Preserve logits for a logits-based loss. This separation makes it easier to verify that confidence plots, threshold selection, and classification decisions all refer to the same probability interpretation.
