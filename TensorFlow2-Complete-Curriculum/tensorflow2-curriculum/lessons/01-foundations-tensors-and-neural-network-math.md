# Lesson 1 — From numbers to tensors and neural network computation

[Course index](../README.md) · [Next lesson](02-autodiff-losses-and-optimization.md)

## How to approach this chapter

This course assumes you can read ordinary Python, but it does not assume that you remember linear algebra, calculus, probability, or neural networks. We rebuild the required mathematics where it becomes useful. You do not need to understand all of advanced mathematics before writing your first model. You do need to know what each array represents and why an operation is meaningful.

Read this chapter in several sittings. The section boundaries are natural stopping points. The aim is to make a small collection of ideas familiar: a model computes predictions; a tensor stores numerical values with a shape; a variable holds adjustable state; and a neural network composes simple mathematical functions. Later chapters explain how the adjustable state is learned.

The examples in this course use TensorFlow 2 with the TensorFlow-backed Keras API. Modern TensorFlow releases use Keras 3 by default. We consistently import `keras` from `tensorflow` rather than mixing legacy Keras packages. The APIs are selected for a TensorFlow 2.20 learning environment; that is a chosen reference version, not a claim that it is the newest release. See [the source and compatibility notes](../SOURCES.md).

## 1. The problem a machine learning framework solves

Imagine a program that predicts electricity consumption from outside temperature and building area. A conventional program might encode manually chosen rules. A learned program instead defines a family of possible relationships and adjusts its parameters using examples. For a deliberately simple family, write

\[
\widehat y = w_1 x_1 + w_2 x_2 + b.
\]

The inputs are temperature and area. The output is predicted consumption. The two weights express how much each input contributes, while the bias supplies a baseline. The hat on the prediction distinguishes an estimate from the observed target. A target is the value we want the program to predict, such as measured consumption.

This equation is a model even though it contains no hidden layers. A model is a parameterized computation. A neural network is one kind of model whose computation is built from layers and nonlinear functions. The word learning means choosing parameter values using data and an objective. It does not mean that the computer acquires a general understanding of electricity or buildings.

Why use TensorFlow instead of writing this formula in Python? For two inputs, ordinary Python is enough. For millions of examples and millions of parameters, we need efficient array operations, derivatives of large computations, structured parameter management, batching, accelerator execution, and serialization. TensorFlow supplies these capabilities. Keras adds convenient layers and training interfaces on top.

Keep three responsibilities separate. The mathematical model determines what relationships can be represented. The training procedure determines how parameters are selected. The evaluation design determines whether performance estimates mean anything outside the training examples. A framework helps implement all three, but it cannot choose a valid scientific question for you.

## 2. Set up a small, reproducible environment

Use Python 3.11 as a conservative reference environment for this course. Create a dedicated environment so another project cannot silently replace your dependencies. On Linux, macOS, or WSL, the basic workflow is:

```bash
python3.11 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
```

Run those commands from the course folder. The requirements file selects TensorFlow 2.20.0. Once installation succeeds on your own machine, record the resolved dependency versions with `python -m pip freeze > environment.lock.txt`. A requirements file with a top-level pin is useful, but the resolved lock records more of the actual environment.

In Windows PowerShell, environment activation uses a different path:

```powershell
py -3.11 -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
```

These examples target CPU execution first. A CPU is enough for the small datasets throughout the course. For NVIDIA GPU acceleration on Windows with modern TensorFlow, follow the official WSL2 installation guide rather than installing old CUDA packages from a TensorFlow 1 tutorial. Native Windows GPU support has different historical constraints. Do not spend your first learning session debugging an accelerator that the examples do not require.

Create a file called `environment_check.py` containing:

```python
import sys
import tensorflow as tf
from tensorflow import keras

print("Python:", sys.version.split()[0])
print("TensorFlow:", tf.__version__)
print("Keras:", keras.__version__)
print("Devices:", tf.config.list_physical_devices())
print("Eager:", tf.executing_eagerly())
print("Sum:", tf.reduce_sum(tf.constant([1.0, 2.0, 3.0])).numpy())
```

The sum should be `6.0`, and eager execution should be enabled. Device names vary. An empty GPU list is not an installation failure if CPU operations work. Record the version output when reporting a problem; an error message without the package versions often leaves the important cause hidden.

A notebook is convenient for exploration, but it retains variables between cells. If an example behaves strangely, restart the kernel and run its cells in order. A script starts with a cleaner state and is easier to reproduce. The standalone examples included with this curriculum favor scripts for that reason.

## 3. Scalars, vectors, matrices, and tensors

A scalar is one numerical value. A vector is an ordered list of values. A matrix is a rectangular table of values. A tensor generalizes these structures to an arbitrary number of axes. In TensorFlow, a scalar has rank zero, a vector rank one, and a matrix rank two. Here rank means number of axes, not the separate linear algebra concept of matrix rank.

```python
import tensorflow as tf

scalar = tf.constant(3.0)
vector = tf.constant([3.0, 4.0])
matrix = tf.constant([[1.0, 2.0], [3.0, 4.0]])

for value in (scalar, vector, matrix):
    print(value.shape, value.dtype, tf.rank(value).numpy())
```

The shapes are `()`, `(2,)`, and `(2, 2)`. Shape tells us how many entries appear along each axis. Dtype tells us the numerical representation of each entry. A shape of `(4, 3)` means four groups of three numbers, but it does not tell us what those groups mean. We must assign meaning from the task.

For tabular learning, use a convention: the first axis indexes examples, and the second indexes features. If a batch contains four buildings described by temperature, area, and age, its shape is `(4, 3)`. For images, the common TensorFlow convention is `(batch, height, width, channels)`. For token embeddings, it is often `(batch, time, embedding_features)`.

The batch axis is a grouping convenience. It does not add a new physical property to a building or an image. Instead, it lets the framework process several examples together. In a properly designed prediction function, one building should normally receive the same prediction regardless of which unrelated buildings share its inference batch. Training-time batch normalization is a notable complication we will examine later.

Write shapes beside unfamiliar computations. Treat them as a lightweight type system. If features are `(batch, features)` and a weight matrix is `(features, outputs)`, matrix multiplication produces `(batch, outputs)`. This simple annotation catches many bugs before they become mysterious optimization problems.

## 4. Dtypes are part of the computation

TensorFlow distinguishes integers, floating-point numbers, booleans, and strings. A float approximates real-valued quantities; an integer represents a discrete count or identifier. An image label such as class `2` is an identifier, not a measurement of twice as much class as label `1`.

```python
import tensorflow as tf

counts = tf.constant([1, 2, 3], dtype=tf.int32)
measurements = tf.cast(counts, tf.float32)
print(measurements / 2.0)
```

The cast changes representation. It does not establish that the represented quantity has become continuous or differentiable. Later, an integer token ID will select an embedding row; gradients update the selected embedding values, not the integer ID itself.

Most small neural networks use float32 for parameters and arithmetic. Float64 offers more precision at a higher memory cost and may run slower on accelerators. Float16 is smaller but has a more restricted numerical range. Mixed precision combines representations strategically; it is an optimization to investigate after a correct float32 baseline exists.

Do not assume that TensorFlow performs every implicit numeric conversion that Python or NumPy would allow. If an operation reports incompatible dtypes, inspect its actual operands. Explicitly cast at a data boundary. Scattering arbitrary casts throughout the model can hide an upstream parsing mistake.

Finite precision also changes how we reason about equality. In exact arithmetic, three additions of one tenth equal three tenths. In floating-point arithmetic, different operation orders may produce slightly different approximations. Compare computations with a tolerance when testing numerical equivalence, and investigate differences that are large relative to the scale of the values.

## 5. Elementwise operations and broadcasting

An elementwise operation acts on corresponding entries. If two tensors have shape `(2, 2)`, their sum has the same shape. Multiplication written with `*` is also elementwise; it is not matrix multiplication.

```python
import tensorflow as tf

features = tf.constant([[1.0, 10.0], [2.0, 20.0]])
offsets = tf.constant([0.5, 1.0])
print((features + offsets).numpy())
print((features * 2.0).numpy())
```

The first result is `[[1.5, 11.0], [2.5, 21.0]]`. TensorFlow applies the feature offsets to each row. Broadcasting allows an operation between compatible shapes without requiring you to manually duplicate the smaller tensor.

To determine compatibility, compare dimensions from the right. Corresponding dimensions must either match or have size one. Missing leading dimensions act like size one. Thus `(batch, features)` and `(features,)` are compatible. The feature vector is logically repeated across examples.

Broadcasting is convenient precisely because it is permissive, so it can also conceal mistakes. Suppose predictions have shape `(batch, 1)` while targets have shape `(batch,)`. Their subtraction can produce a `(batch, batch)` table comparing every prediction with every target. That is a valid tensor operation implementing the wrong learning problem.

```python
import tensorflow as tf

predictions = tf.constant([[1.0], [2.0], [3.0]])
targets = tf.constant([1.0, 2.0, 3.0])
wrong_residuals = predictions - targets
right_residuals = predictions - targets[:, None]
print(wrong_residuals.shape)  # (3, 3)
print(right_residuals.shape)  # (3, 1)
```

The expression `targets[:, None]` keeps every target and inserts a length-one axis. It changes `(3,)` to `(3, 1)`. This example is worth understanding before reading any loss function: an apparently decreasing loss can still optimize an accidental all-pairs comparison.

## 6. Dot products as weighted evidence

A dot product multiplies corresponding entries and sums the products. If a building has two standardized features `[2, -1]` and weights are `[0.5, 3]`, the weighted score is `2(0.5) + (-1)(3) = -2`. Each feature contributes according to its weight, and the result summarizes those contributions in one number.

Geometrically, a dot product also measures alignment. Two vectors pointing in similar directions have a positive dot product; perpendicular vectors have zero dot product. This interpretation becomes useful for attention and embedding similarity. Its limit is that vector length also changes the dot product. A large score may reflect larger magnitude rather than closer angular alignment.

```python
import tensorflow as tf

features = tf.constant([2.0, -1.0])
weights = tf.constant([0.5, 3.0])
score = tf.reduce_sum(features * weights)
print(score.numpy())  # -2.0
```

The reduction sums across the remaining axis. Reductions remove information about individual entries, so always ask which axis is being reduced. For a batch of examples, summing over the feature axis yields one score per example; summing over every axis yields one number for the entire batch.

A linear prediction adds a bias to the dot product. The bias allows a nonzero output when all inputs are zero. If features are centered, zero corresponds to an average feature configuration, making the bias interpretable as a baseline at that reference point. Without centering, zero may describe an unrealistic building, and that interpretation becomes less useful.

## 7. Matrix multiplication evaluates many dot products

Matrix multiplication organizes dot products efficiently. Let `features` have shape `(3, 2)` and `weights` have shape `(2, 1)`. Each of the three rows becomes a prediction using the same two weights.

```python
import tensorflow as tf

features = tf.constant([[2.0, -1.0], [0.0, 1.0], [1.0, 1.0]])
weights = tf.constant([[0.5], [3.0]])
bias = tf.constant([1.0])
predictions = tf.matmul(features, weights) + bias
print(predictions.numpy())
```

The output is `[[-1.0], [4.0], [4.5]]`. For the first row, the dot product was `-2`, and adding the bias gives `-1`. The other rows follow the same rule. The parameters are shared across examples; we are not learning a separate rule for each row.

If we want four outputs instead of one, use weights with shape `(2, 4)` and bias with shape `(4,)`. Each column of the weight matrix defines a separate weighted score. The output shape becomes `(3, 4)`. A dense neural network layer is essentially this matrix multiplication plus bias, followed optionally by an activation function.

The inner dimensions must agree because every input feature needs a corresponding weight. A mismatch such as `(3, 2) @ (3, 4)` is not a nuisance to bypass with random reshaping. It says the model's mathematical contract is inconsistent. Inspect whether the data or the weight layout is wrong.

The symbol `@` is Python's matrix multiplication operator. For ordinary rank-two tensors, `features @ weights` and `tf.matmul(features, weights)` express the same operation. Use the form that makes the surrounding teaching example clearest. For higher-rank batched products, inspect the last two axes and the broadcasting of the leading axes carefully.

## 8. Reshape changes grouping; transpose changes axis order

Suppose a grayscale image has four pixels arranged as a two-by-two grid. Flattening it into a length-four vector preserves its values but removes the explicit grid structure. A dense layer can consume that vector; a convolutional layer makes explicit use of the grid instead.

```python
import tensorflow as tf

image = tf.constant([[1.0, 2.0], [3.0, 4.0]])
print(tf.reshape(image, [4]).numpy())
print(tf.transpose(image).numpy())
```

The flattened vector is `[1, 2, 3, 4]`. The transposed matrix is `[[1, 3], [2, 4]]`. Reshape reinterprets the sequence of values with a new shape. Transpose rearranges which axis indexes which direction. They solve different problems.

A reshape must preserve the number of elements. The special dimension `-1` asks TensorFlow to infer one dimension from the others. If a batch contains five images of shape `(2, 2, 1)`, `tf.reshape(images, [5, -1])` produces `(5, 4)`. Avoid inferring the batch size carelessly when doing so might combine examples.

Slicing also changes shapes. For `features` of shape `(batch, 2)`, `features[:, 0]` has shape `(batch,)`, while `features[:, 0:1]` has shape `(batch, 1)`. Both select the first feature, but they preserve different axis structures. The distinction matters when broadcasting against column-shaped predictions.

Some operations accept negative axis numbers. Axis `-1` means the last axis, independent of rank. Reducing class probabilities along `axis=-1` is often clearer than hard-coding a class axis number that changes when a batch dimension is introduced.

## 9. Statistical scaling is a mathematical choice

Temperature may vary by tens of degrees, while building area varies by thousands of square feet. A large numerical feature scale can dominate gradient magnitudes even when the underlying feature is not more predictive. Standardization makes numerical scales more comparable:

\[
z_j = \frac{x_j-\mu_j}{\sigma_j}.
\]

Here the mean and standard deviation are computed separately for each feature. A standardized value of one means one training standard deviation above the training mean. It is not a probability and does not restrict values to the interval zero to one.

```python
import tensorflow as tf

training_features = tf.constant(
    [[10.0, 1000.0], [20.0, 1500.0], [30.0, 2000.0]],
    dtype=tf.float32,
)
mean = tf.reduce_mean(training_features, axis=0)
variance = tf.reduce_mean(tf.square(training_features - mean), axis=0)
scale = tf.sqrt(variance)
standardized = (training_features - mean) / tf.maximum(scale, 1e-7)
print(tf.reduce_mean(standardized, axis=0).numpy())
```

The feature means should be near zero. The maximum in the denominator prevents division by zero for a constant feature. This manual computation uses population variance for the training array; statistical estimators may use a different denominator for different purposes.

The crucial engineering rule is to fit the transformation using training data only. Validation and test examples must be transformed using the stored training statistics. Otherwise, information from the evaluation distribution influences the training process. Even a label-free transformation can create leakage when fitted across all available data.

Standardization is not always appropriate. Binary indicators already have a clear scale. Pretrained image models require their own preprocessing conventions. Embedding indices should never be standardized as if neighboring IDs carried numerical distance. Choose preprocessing according to what values mean, not just their dtype.

## 10. From a linear map to a neural network

A linear map followed by another linear map is still linear, apart from the accumulated bias. If `h = xW_1 + b_1` and `y = hW_2 + b_2`, substitution gives `y = x(W_1W_2) + b_1W_2 + b_2`. Stacking those maps alone does not create a more expressive nonlinear family.

An activation function changes that. The rectified linear unit is

\[
\operatorname{ReLU}(a)=\max(0,a).
\]

It preserves positive inputs and sets negative inputs to zero. Different units can activate in different regions of the input space. A subsequent layer can combine these region-dependent responses into a more flexible function.

```python
import tensorflow as tf

features = tf.constant([[1.0, -2.0], [2.0, 1.0]])
first_weights = tf.constant([[1.0, -1.0], [0.5, 0.5]])
first_bias = tf.constant([0.0, 0.0])
second_weights = tf.constant([[2.0], [-1.0]])
second_bias = tf.constant([0.5])

hidden = tf.nn.relu(features @ first_weights + first_bias)
predictions = hidden @ second_weights + second_bias
print("Hidden:", hidden.numpy())
print("Predictions:", predictions.numpy())
```

Every row still represents an example. Every hidden column represents a learned intermediate feature. The hidden features are not required to correspond to human-named concepts. Their usefulness comes from helping the model produce good predictions under the chosen objective.

A network with two inputs, two hidden units, and one output has four first-layer weights, two first-layer biases, two second-layer weights, and one second-layer bias: nine trainable numbers. Counting parameters makes an architecture less mysterious. A huge network is still a structured collection of numerical parameters and operations, although its behavior can be difficult to interpret.

## 11. Variables hold the state that learning changes

A tensor is a value. A variable is a mutable container for a tensor value. Use constants for fixed inputs in a tiny demonstration and variables for adjustable parameters.

```python
import tensorflow as tf

weight = tf.Variable(1.0, name="weight")
initial_value = weight.read_value()
weight.assign(2.0)
weight.assign_sub(0.25)
print(initial_value.numpy())  # 1.0
print(weight.numpy())         # 1.75
```

The saved `initial_value` tensor remains one because it represents a value read at that point. The variable now contains `1.75`. An optimizer will repeatedly assign new parameter values using derivative information.

Avoid replacing a tracked variable with an unrelated Python object. In custom Keras layers, parameters should be created with `add_weight`, which makes their ownership explicit. In low-level TensorFlow examples, `tf.Variable` is sufficient. Parameter tracking matters because training, saving, and restoration need to discover the same state.

Initialization chooses the starting values before learning. Starting every hidden unit with identical weights can preserve symmetry: identical units receive identical signals and remain identical. Random initialization breaks that symmetry. The scale matters too; excessively large values can destabilize activations or saturate some nonlinearities. Keras supplies initializers designed for common layer and activation combinations.

A random seed helps make a run repeatable, but it does not guarantee identical results across all hardware and software configurations. Some parallel operations have nondeterministic execution orders. For the course's tiny experiments, `keras.utils.set_random_seed(7)` is a useful baseline. Strong reproducibility requires recording the environment, data, split, and computation settings as well.

## 12. Read a minimal Keras model without treating it as magic

We can now express the same computation using layers:

```python
import tensorflow as tf
from tensorflow import keras

keras.utils.set_random_seed(7)
model = keras.Sequential([
    keras.Input(shape=(2,)),
    keras.layers.Dense(4, activation="relu"),
    keras.layers.Dense(1),
])
features = tf.constant([[1.0, 2.0], [3.0, 4.0]])
predictions = model(features, training=False)
print(predictions.shape)
model.summary()
```

`Sequential` connects layers in a straight chain. `Input(shape=(2,))` describes one example with two features; Keras supplies a variable batch dimension. The first dense layer produces four hidden features. The final dense layer produces one real-valued output per example. The output shape is `(2, 1)` for this batch of two.

The first layer has `2 × 4 + 4 = 12` parameters. The second has `4 × 1 + 1 = 5`. The total is seventeen. The exact initial predictions depend on initialization, so their numerical values are not meaningful yet. The shape and parameter count are meaningful immediately.

Calling a model runs its forward computation. It does not automatically train it. Passing `training=False` asks layers with mode-dependent behavior to use inference behavior. Dense layers have the same forward rule in both modes, but dropout and batch normalization do not. We keep the argument explicit when discussing evaluation.

The object-oriented structure should feel familiar if you have used classes in Kotlin, PowerShell, or C#. A model owns layer objects; layer objects own weights; calling a layer applies its behavior. The mathematical relationship is still the one we derived. Object ownership provides a practical way to organize it.

## 13. Probability enters when outputs represent uncertainty

A regression output can be any real number. A binary classifier instead estimates a probability for an event. A common transformation is the sigmoid:

\[
\sigma(z)=\frac{1}{1+e^{-z}}.
\]

It maps any real score, called a logit, to a value between zero and one. A score of zero maps to probability one half. A large positive score approaches one; a large negative score approaches zero. The logit is the logarithm of the odds when the sigmoid probability model is used.

For several mutually exclusive classes, softmax converts a vector of logits into positive values summing to one:

\[
p_k = \frac{e^{z_k}}{\sum_j e^{z_j}}.
\]

```python
import tensorflow as tf

binary_logits = tf.constant([-2.0, 0.0, 2.0])
class_logits = tf.constant([[1.0, 2.0, 3.0]])
print(tf.math.sigmoid(binary_logits).numpy())
print(tf.nn.softmax(class_logits, axis=-1).numpy())
```

The sigmoid outputs are approximately `0.119`, `0.5`, and `0.881`. The softmax assigns the largest probability to the largest logit. Adding the same constant to every class logit leaves softmax unchanged, because the common exponential factor cancels from numerator and denominator.

A neural network producing `0.9` is not automatically calibrated to be correct ninety percent of the time on such predictions. The architecture supplies a probability-shaped output; training and evaluation determine whether that output has a useful uncertainty interpretation. We will distinguish confidence, accuracy, and calibration later.

## 14. Shape reasoning for different learning tasks

The output contract depends on the question. For regression with one target, predictions usually have shape `(batch, 1)` and targets can deliberately use the same shape. For mutually exclusive classification with five classes, logits have shape `(batch, 5)` and sparse integer targets have shape `(batch,)`. A sequence tagger adds a time axis, yielding logits shaped `(batch, time, classes)`.

| Task | Input example | Output per example | Target meaning |
| --- | --- | --- | --- |
| Regression | Feature vector | One real value | Measured quantity |
| Binary classification | Feature vector or image | One logit | Event absent or present |
| Multiclass classification | Image | One logit per class | One class index |
| Multilabel classification | Document | One logit per label | Several independent indicators |
| Sequence tagging | Token sequence | Class logits at each position | One tag per real token |

Do not use a softmax merely because there are several output numbers. Softmax assumes the modeled outcomes compete for one unit of total probability. A document can simultaneously concern security and databases; independent sigmoid outputs can represent those labels without forcing them to compete.

Similarly, a time series window and an unordered feature vector may both be rank two for one example, yet they require different reasoning. Shapes specify arrangement, not statistical assumptions. A model architecture adds assumptions about locality, ordering, parameter sharing, and interactions.

## 15. Debug numerical programs in a deliberate order

Start with one example and print its value, dtype, and shape at each major boundary. Verify a hand-calculated result before adding a large dataset. A tensor framework makes wrong computations fast as readily as correct ones.

Use assertions to make assumptions executable:

```python
import tensorflow as tf

features = tf.constant([[1.0, 2.0], [3.0, 4.0]])
targets = tf.constant([[5.0], [6.0]])
tf.debugging.assert_rank(features, 2)
tf.debugging.assert_equal(tf.shape(features)[0], tf.shape(targets)[0])
tf.debugging.assert_all_finite(features, "Features contain NaN or infinity")
```

An assertion documents the expected contract and stops execution close to a violation. This is more useful than discovering several layers later that the loss became `NaN`. Once a model works, retain checks at important external data boundaries rather than printing every intermediate tensor forever.

When an operation fails, translate the message into a mathematical question. An incompatible matrix multiplication asks whether feature counts agree. A dtype mismatch asks whether two representations were intentionally combined. A non-finite value asks where the numerical domain was violated, such as dividing by zero or taking the logarithm of zero.

Optimization is not a substitute for these checks. Changing the learning rate cannot fix a target-axis bug. A deeper network cannot repair a leaked split. More epochs cannot restore feature information discarded by an incorrect reshape. The fastest route to a reliable training run is usually a correct small forward computation.

## 16. A complete forward-pass laboratory

The following program ties together scaling, variables, matrix multiplication, nonlinearities, and output contracts. It does not train; it gives every intermediate value an explicit meaning.

```python
import tensorflow as tf

raw_features = tf.constant([[10.0, 1000.0], [20.0, 1500.0]])
reference_mean = tf.constant([15.0, 1250.0])
reference_scale = tf.constant([5.0, 250.0])
features = (raw_features - reference_mean) / reference_scale

hidden_weights = tf.Variable([[1.0, -1.0], [1.0, 1.0]])
hidden_bias = tf.Variable([0.0, 0.0])
output_weights = tf.Variable([[0.5], [1.0]])
output_bias = tf.Variable([2.0])

hidden = tf.nn.relu(features @ hidden_weights + hidden_bias)
predictions = hidden @ output_weights + output_bias

tf.debugging.assert_equal(tf.shape(predictions), [2, 1])
print("Scaled features:", features.numpy())
print("Hidden features:", hidden.numpy())
print("Predictions:", predictions.numpy())
```

The scaled feature rows are `[-1, -1]` and `[1, 1]`. Their hidden preactivations are `[-2, 0]` and `[2, 0]`. ReLU changes the first row to `[0, 0]` and leaves the positive two in the second row. The resulting predictions are `2` and `3`. You can verify every step with ordinary arithmetic.

The reference statistics here are specified constants to keep the demonstration transparent. A real workflow estimates them from a training partition, then stores them with the model. A forward demonstration does not establish that the chosen weights are useful, only that the computation implements the intended formulas.

## 17. What has been established

You can now describe a neural network without invoking hidden machinery: organize examples into tensors, transform input scales, multiply by parameter matrices, add biases, apply nonlinearities, and produce outputs with a task-specific interpretation. The same principles scale to image, text, and generative systems.

The remaining question is how to select useful weights. Manually choosing thousands of parameters is impractical. The next lesson introduces a loss that measures prediction quality, derives derivatives that describe local sensitivity, and uses those derivatives to improve parameters. That connects the numerical program you have already understood to the learning process.

For optional application, replace the laboratory's last weight vector and observe how the two predictions change. This is a small engineering experiment, not a prerequisite quiz. The important habit is to connect a changed parameter to a changed computation before asking an optimizer to change it automatically.

Further reading: [TensorFlow basics](https://www.tensorflow.org/guide/basics), [tensors](https://www.tensorflow.org/guide/tensor), [variables](https://www.tensorflow.org/guide/variable), and [installation](https://www.tensorflow.org/install/pip). The explanations and calculations above are original teaching material; official links document the corresponding library behavior.

## Extended study — Geometry, dynamic shapes, and the limits of representation

### Norms connect vector size to optimization

A norm measures vector magnitude. The Euclidean norm is the square root of the sum of squared coordinates. For `[3, 4]`, that is five. The squared norm is twenty-five. These quantities appear in parameter penalties, distance-based models, gradient clipping, and numerical diagnostics.

```python
import tensorflow as tf

vector = tf.constant([3.0, 4.0])
print(tf.norm(vector).numpy())  # 5.0
unit_vector = vector / tf.norm(vector)
print(unit_vector.numpy())     # [0.6, 0.8]
print(tf.reduce_sum(tf.square(unit_vector)).numpy())  # approximately 1.0
```

Dividing a nonzero vector by its norm separates direction from magnitude. Cosine similarity is the dot product of such normalized vectors. It emphasizes alignment rather than raw length. That is useful for some retrieval systems, but magnitude may contain useful information in another model. Normalization is therefore a representational choice, not a universal improvement.

At the zero vector, direction is undefined. Implementations often introduce an epsilon to avoid division by zero, but the resulting finite output does not create missing geometric information. Handle such cases according to the task rather than treating numerical finiteness as semantic validity.

### Linear maps can lose information

A matrix mapping four input features to two outputs cannot preserve every independent direction in the original four-dimensional space. Different inputs can produce the same output. A learned bottleneck exploits this loss of information when irrelevant variation can be discarded, but it can also discard details needed for a later task.

An eigenvector is a direction that a square linear map scales without changing its direction. Singular value decomposition generalizes a related geometric view to rectangular matrices: rotate or reorient input coordinates, scale along orthogonal directions, then reorient outputs. Small singular values indicate directions that the map strongly compresses.

You do not need to compute an SVD for every dense layer. The useful intuition is that matrices can stretch, shrink, rotate, and collapse directions. Repeated transformations can amplify or suppress sensitivities, connecting linear algebra to the gradient behavior discussed in Lesson 2.

Principal component analysis chooses orthogonal directions of large variation in centered data. It can provide a simple compression baseline. Large variation does not necessarily mean high predictive value: a low-variance feature may carry the target signal while high-variance features describe irrelevant nuisance factors. Unsupervised geometry and supervised usefulness are different criteria.

### Static and runtime shapes answer different questions

A tensor's `.shape` describes shape information known to the program at that point. `tf.shape(tensor)` computes a shape tensor available during execution. In eager examples both often look fully specified. Inside traced functions, a batch dimension can be unknown statically while having an ordinary concrete value on each call.

```python
import tensorflow as tf

@tf.function(input_signature=[tf.TensorSpec([None, 2], tf.float32)])
def inspect_shape(features):
    tf.print("Runtime shape:", tf.shape(features))
    return tf.reshape(features, [tf.shape(features)[0], 2])

result = inspect_shape(tf.ones([7, 2]))
print(result.shape)
```

The input signature intentionally leaves batch length flexible. Runtime operations can use its actual value. This is useful when the last batch is smaller than earlier ones. Hard-coding a batch size into every reshape makes otherwise valid data fail at that final batch.

### Approximation capacity does not establish reliability

A sufficiently expressive neural network family can approximate many functions under suitable assumptions. That mathematical capacity does not prove a particular training run will find the desired function, that the dataset contains enough information, or that evaluation covers deployment conditions.

Separate representation, optimization, and generalization whenever reading a strong claim. Representation asks whether a solution exists within the family. Optimization asks whether the procedure finds useful parameters. Generalization asks how the chosen function behaves beyond its training examples. TensorFlow implements computations involved in all three, but the questions remain logically distinct.
