# Lesson 2 — How neural networks learn: derivatives, losses, and optimization

[Previous lesson](01-foundations-tensors-and-neural-network-math.md) · [Course index](../README.md) · [Next lesson](03-keras-data-and-reliable-experiments.md)

## 1. Turn a prediction program into a learning problem

The previous chapter built a function from inputs to predictions. Its parameters were deliberately chosen by hand. To learn parameters, we need a numerical definition of an undesirable prediction and a procedure that makes that number smaller. The undesirable quantity is a loss. The procedure is an optimizer.

Begin with the smallest useful example. An input is a single real number, the prediction is `weight * input + bias`, and the observed target is another real number. Write the prediction as \(\widehat y=wx+b\). For one training example, squared error is \(\ell=(\widehat y-y)^2\). When the prediction equals the target, the loss is zero. Errors of equal magnitude in opposite directions have the same loss.

Take input two, target five, weight one, and bias zero. The prediction is two and the residual, prediction minus target, is negative three. Squaring yields nine. We want to change the parameters so that a future prediction for this example moves toward five. Increasing the weight slightly would increase the prediction and reduce this particular error.

The word slightly matters. A local direction that helps for a small step can hurt for a large step. If the weight jumps from one to one hundred, the prediction becomes two hundred and the squared error becomes enormous. Learning is not simply choosing the correct sign; it requires controlling update size.

For a dataset of \(N\) examples, mean squared error averages the individual squared errors:

\[
L(w,b)=\frac{1}{N}\sum_{i=1}^{N}(wx_i+b-y_i)^2.
\]

The mean makes the scale less dependent on the number of examples. It also defines how examples contribute: each receives equal weight unless we deliberately introduce sample weighting. A loss function is an engineering and statistical choice, not an inevitable property of the framework.

## 2. Derivatives measure local sensitivity

A derivative answers a precise question: how fast does an output change when an input changes near its current value? For \(f(w)=w^2\), increasing the weight by a small amount \(h\) changes the output by

\[
(w+h)^2-w^2=2wh+h^2.
\]

Divide by \(h\) to obtain average change per unit input: \(2w+h\). As the step approaches zero, this approaches \(2w\). That limiting rate is the derivative. At weight three, the local sensitivity is six. A small positive change in weight produces approximately six times that change in the output.

This derivation is useful because it shows what the derivative does and does not say. It describes a local linear approximation. It is exact for the instantaneous rate, not a promise that the same rate holds over a large interval. Gradient descent repeatedly recomputes local information after moving.

For several parameters, a partial derivative changes one parameter while holding the others fixed. The gradient collects these partial derivatives into a vector. If a model has a million adjustable numbers, its gradient contains a million corresponding sensitivities. Parameters stored in a matrix receive a gradient matrix with the same shape.

The gradient of a scalar loss points toward the steepest local increase under the ordinary Euclidean geometry of parameter space. Moving opposite the gradient therefore gives a locally decreasing direction when the gradient is nonzero and the step is sufficiently small. It does not guarantee the best possible final model or the best direction under every alternative geometry.

The first-order approximation makes the rule explicit:

\[
L(\theta+\Delta)\approx L(\theta)+\nabla L(\theta)^\top\Delta.
\]

Choose \(\Delta=-\eta\nabla L\), where \(\eta\) is positive. The predicted change is \(-\eta\|\nabla L\|^2\), which is nonpositive. Approximation error explains why an excessive learning rate can still increase the actual loss.

## 3. The chain rule connects prediction errors to parameters

A neural network is a composition of operations. For our scalar example, first compute a prediction, then a residual, then its square. Name these intermediate quantities:

\[
p=wx+b,\qquad r=p-y,\qquad \ell=r^2.
\]

The derivative of the loss with respect to the residual is \(2r\). The derivative of the residual with respect to prediction is one. The derivative of prediction with respect to weight is \(x\). Multiplying along the chain gives

\[
\frac{\partial\ell}{\partial w}=2rx,
\qquad
\frac{\partial\ell}{\partial b}=2r.
\]

For input two and residual negative three, the weight derivative is negative twelve and the bias derivative is negative six. With learning rate `0.1`, subtracting these derivatives changes the weight to `2.2` and the bias to `0.6`. The new prediction is five, so this single-example update happens to land exactly on the target. That exact result is a property of these numbers, not a general convergence guarantee.

For multiple examples, the derivative of the mean is the mean of their derivatives. Some examples may ask the weight to increase while others ask it to decrease. The aggregate update compromises according to the objective. This is why inspecting one prediction cannot fully explain a dataset-level gradient.

Backpropagation applies this chain-rule reasoning efficiently through a whole network. It propagates loss sensitivity backward through the forward operations. It is not a second model guessing better weights. It is a systematic derivative computation for the model we already defined.

## 4. Automatic differentiation with GradientTape

TensorFlow records differentiable operations executed inside a gradient tape context. After computing a scalar loss, ask the tape for its derivatives with respect to chosen variables.

```python
import tensorflow as tf

weight = tf.Variable(1.0)
bias = tf.Variable(0.0)
feature = tf.constant(2.0)
target = tf.constant(5.0)

with tf.GradientTape() as tape:
    prediction = weight * feature + bias
    loss = tf.square(prediction - target)

weight_gradient, bias_gradient = tape.gradient(loss, [weight, bias])
print(loss.numpy())             # 9.0
print(weight_gradient.numpy())  # -12.0
print(bias_gradient.numpy())    # -6.0

weight.assign_sub(0.1 * weight_gradient)
bias.assign_sub(0.1 * bias_gradient)
print((weight * feature + bias).numpy())  # approximately 5.0
```

The `with` statement creates a recording region. Trainable variables used inside it are watched automatically. The gradient call returns results in the same structure as the requested sources. Assigning new values occurs after derivative computation, so the derivatives correspond to the original forward pass.

The tape records executed TensorFlow operations, not arbitrary mathematical intent. Converting an intermediate to NumPy and performing downstream arithmetic there breaks the TensorFlow differentiation path. Similarly, computing the forward pass before entering the tape leaves no recorded path for that computation.

A nonpersistent tape supports one gradient call. If several derivative queries are necessary, a persistent tape can retain the recording, but it uses additional memory and should be released afterward. Most training steps need only one call returning gradients for all trainable variables.

To differentiate with respect to a constant input, explicitly watch it:

```python
import tensorflow as tf

feature = tf.constant(3.0)
with tf.GradientTape() as tape:
    tape.watch(feature)
    output = feature ** 3
print(tape.gradient(output, feature).numpy())  # 27.0
```

This capability is useful for sensitivity analysis and some scientific models. It does not turn every input representation into a meaningful optimization variable. Derivatives with respect to discrete token IDs are not defined by ordinary embedding lookup semantics.

## 5. Numerical differentiation is a diagnostic, not the training engine

A finite difference approximates a derivative by evaluating the loss at neighboring parameter values:

\[
f'(w)\approx\frac{f(w+\varepsilon)-f(w-\varepsilon)}{2\varepsilon}.
\]

This central difference is useful for checking a small differentiable calculation. It is expensive for a large parameter vector because checking every coordinate requires many forward evaluations. Automatic differentiation instead exploits the structure of the executed computation.

```python
import tensorflow as tf

weight = tf.Variable(1.3, dtype=tf.float64)

def objective(value):
    return tf.square(2.0 * value - 5.0)

with tf.GradientTape() as tape:
    loss = objective(weight)
automatic = tape.gradient(loss, weight)
epsilon = tf.constant(1e-5, dtype=tf.float64)
numerical = (objective(weight + epsilon) - objective(weight - epsilon)) / (2 * epsilon)
print(automatic.numpy(), numerical.numpy())
```

Both values should be close to negative `9.6`. Float64 reduces some numerical error in this tiny diagnostic. An extremely tiny epsilon can make subtraction cancellation worse, while a large epsilon makes the approximation less local. Choose a moderate perturbation relative to the quantity's scale.

Avoid gradient checking exactly at a nondifferentiable point such as ReLU at zero. The left and right derivatives differ there, and a symmetric finite difference need not equal the convention used by the automatic derivative. Also disable stochastic operations when comparing derivatives; two different dropout masks create different functions rather than a meaningful derivative discrepancy.

## 6. Backpropagation through a dense layer

For a batch, write \(Z=XW+b\), with shapes `(B, D)`, `(D, H)`, and `(H,)`. Let \(G=\partial L/\partial Z\) have shape `(B, H)`. Then

\[
\frac{\partial L}{\partial W}=X^\top G,
\quad
\frac{\partial L}{\partial b}=\sum_{i=1}^{B}G_i,
\quad
\frac{\partial L}{\partial X}=GW^\top.
\]

These expressions follow from tracking how each output entry depends on each input and parameter. A weight contributes to every example, so its derivative sums contributions across the batch. A bias contributes equally to a particular hidden unit in every example, so its derivative sums that column of sensitivities.

If the loss already includes division by batch size, that scaling is already present in `G`; do not divide again automatically. Reduction conventions matter. A loss gradient and a model gradient must refer to the same exact scalar objective.

After ReLU, the backward sensitivity passes through where the preactivation is positive and becomes zero where it is negative. A unit that remains negative on every training example may receive no useful gradient through its activation. This is one reason initialization and learning rate affect trainability.

The formulas reveal why shapes are so valuable. `X` transposed has shape `(D, B)`, so multiplying by `G` yields `(D, H)`, exactly matching `W`. When TensorFlow returns an unexpected gradient shape, the underlying forward contract deserves inspection.

## 7. Regression losses reflect assumptions

Mean squared error strongly penalizes large residuals. A residual of ten contributes one hundred, whereas a residual of one contributes one. A small number of extreme targets can therefore dominate training. This may be desirable if large errors are truly costly, or undesirable if those extremes are corrupted measurements.

Mean absolute error uses \(|\widehat y-y|\). Its sensitivity has constant magnitude away from zero, making it less dominated by very large residuals. Huber loss behaves quadratically near zero and approximately linearly farther away, providing a transition controlled by a threshold.

| Loss | Local behavior | Practical implication |
| --- | --- | --- |
| Squared error | Smooth quadratic | Strong pressure on large errors |
| Absolute error | Linear magnitude | More robust to extreme residuals |
| Huber | Quadratic then linear | Combines smooth fitting and robustness |

There is also a probability interpretation. If targets equal predictions plus independent Gaussian noise with fixed variance, minimizing negative log likelihood reduces to minimizing squared error up to constants and scale. If noise assumptions change, the statistically appropriate objective may change too. This does not mean real residuals must be perfectly Gaussian for MSE to be useful.

Targets with different units need care. Predicting both temperature and annual revenue with an unweighted sum of squared errors can let revenue dominate numerically. Standardize targets or choose justified task weights, then report errors back in meaningful units. A lower dimensionless loss is not by itself a better user outcome.

## 8. Binary cross-entropy from a Bernoulli model

A binary label is zero or one. Suppose a model assigns probability \(p\) to label one. The probability of the observed label is \(p^y(1-p)^{1-y}\). Taking the negative logarithm gives

\[
\ell=-y\log p-(1-y)\log(1-p).
\]

For a positive example, the loss is `-log(p)`: probability close to one is rewarded, while confident rejection is heavily penalized. For a negative example, the relevant term is `-log(1-p)`. This is cross-entropy for the Bernoulli distribution.

Implement it from logits rather than manually taking logarithms of sigmoid outputs. TensorFlow can combine the operations in a numerically stable expression. Very large positive or negative logits otherwise risk probabilities rounding to one or zero before a logarithm is evaluated.

```python
import tensorflow as tf
from tensorflow import keras

labels = tf.constant([[1.0], [0.0]])
logits = tf.constant([[2.0], [-2.0]])
loss_function = keras.losses.BinaryCrossentropy(from_logits=True)
print(loss_function(labels, logits).numpy())  # approximately 0.1269
print(tf.math.sigmoid(logits).numpy())
```

The final model layer should have no sigmoid activation when `from_logits=True`. Use sigmoid when interpreting predictions. Applying sigmoid first while also declaring logits makes the loss interpret probabilities as raw scores and optimizes a different expression.

An especially useful derivative is \(\partial\ell/\partial z=\sigma(z)-y\). The combined sigmoid-cross-entropy gradient expresses predicted probability minus observed outcome. A confident incorrect prediction therefore produces a substantial correction signal, unlike some poorly chosen combinations of activation and squared error.

The usual probability threshold of one half is a decision rule, not part of the learned distribution itself. If missing a positive case is much more costly than investigating a false alarm, choose a threshold using validation data and an explicit cost or recall requirement. Never tune it on the final test set.

## 9. Multiclass cross-entropy and label encoding

For one of `C` mutually exclusive classes, softmax supplies class probabilities. If the true class is `k`, negative log likelihood is \(-\log p_k\). Sparse categorical cross-entropy accepts `k` as an integer class index. Categorical cross-entropy accepts a one-hot or other class distribution target.

```python
import tensorflow as tf
from tensorflow import keras

labels = tf.constant([2, 0], dtype=tf.int32)
logits = tf.constant([[1.0, 2.0, 3.0], [3.0, 1.0, 0.0]])
loss_function = keras.losses.SparseCategoricalCrossentropy(from_logits=True)
print(loss_function(labels, logits).numpy())
print(tf.argmax(logits, axis=-1).numpy())  # [2, 0]
```

The logits have shape `(2, 3)` and labels shape `(2,)`. Taking `argmax` before the loss would discard confidence and introduce a nondifferentiable class-selection step. Keep continuous scores through the loss; convert to class decisions only for reporting or downstream action.

The softmax-cross-entropy derivative for each class logit is predicted probability minus the corresponding one-hot target. Increasing the correct class logit and decreasing competing logits can therefore reduce the loss. Adding the same offset to all logits changes no probabilities, which explains a degree of redundancy in the parameterization.

For multilabel problems, use separate binary losses for the labels rather than categorical cross-entropy. For sequence tagging, apply categorical loss at real token positions and mask padding. These choices all follow from the event being modeled; they are not interchangeable naming preferences.

## 10. A complete low-level learning loop

Now fit a synthetic linear relationship. Synthetic data is useful because the data-generating mechanism is known, allowing us to distinguish implementation errors from an inherently difficult prediction task.

```python
import tensorflow as tf
from tensorflow import keras

keras.utils.set_random_seed(11)
features = tf.reshape(tf.linspace(-1.0, 1.0, 128), [-1, 1])
targets = 3.0 * features + 2.0
weight = tf.Variable([[0.0]])
bias = tf.Variable([0.0])
optimizer = keras.optimizers.SGD(learning_rate=0.1)

for step in range(200):
    with tf.GradientTape() as tape:
        predictions = features @ weight + bias
        loss = tf.reduce_mean(tf.square(predictions - targets))
    gradients = tape.gradient(loss, [weight, bias])
    optimizer.apply_gradients(zip(gradients, [weight, bias]))
    if step % 50 == 0:
        print(step, float(loss.numpy()))

print("Weight:", weight.numpy())
print("Bias:", bias.numpy())
```

The weight should approach three, the bias two, and the loss should become small. Each iteration performs a forward computation, builds one scalar objective, differentiates that objective, and updates the same variables. The optimizer object persists across steps; recreating an adaptive optimizer every batch would erase its accumulated state.

This program uses the whole dataset for every step. That is full-batch gradient descent. It is simple and deterministic enough for teaching. Larger datasets generally use smaller minibatches to reduce per-step computation and provide more frequent updates.

The loss printed at a step was computed before that step's update. This ordering is normal, but remember it when comparing logged values to predictions calculated afterward. A metric is always attached to particular parameter values and data, even if a training interface hides some timing details.

## 11. Minibatches, epochs, and stochastic optimization

A batch is the collection of examples used in one update. An epoch usually means one pass through the training examples. If there are 1,000 examples and batch size 100, a straightforward epoch contains ten updates. A remainder batch may be smaller unless deliberately dropped.

The minibatch gradient estimates the full training gradient. Shuffling changes which examples contribute together, reducing order effects. It also introduces variation: consecutive updates can have different loss values even while the overall model improves. A single high batch loss is not evidence that training has failed.

A small batch uses less memory and may make more updates for a fixed number of epochs. A large batch can use hardware more efficiently but changes optimization dynamics and the number of updates. Comparing two runs by epoch count alone can therefore be misleading. Track examples processed, update count, and wall-clock time according to the question being investigated.

Data order can carry information. If examples are sorted by class, an unshuffled sequence of minibatches may train on one class at a time. For time series, however, careless shuffling before constructing valid windows can create leakage or destroy the intended forecasting task. Split design comes before generic batching recipes.

For independent training examples, a dataset can shuffle, batch, and prefetch. The next lesson develops those transformations carefully. Here the central idea is that batching changes the gradient estimate, while the underlying per-example loss retains the same meaning.

## 12. Momentum and Adam make updates stateful

Plain SGD takes a scaled step against the current gradient. Momentum maintains a moving direction that combines recent gradients. It can smooth noisy updates and accelerate progress along directions with persistent gradients. The exact parameterization depends on the optimizer implementation, but the practical idea is accumulated directional information.

Adam maintains moving estimates of first and second gradient moments. Informally, it combines a smoothed direction with coordinate-dependent normalization based on recent squared gradients. It also corrects early moving-average bias. These mechanisms often make it a useful default, but they do not remove the need to choose an appropriate learning rate.

```python
from tensorflow import keras

sgd = keras.optimizers.SGD(learning_rate=0.01, momentum=0.9)
adam = keras.optimizers.Adam(learning_rate=0.001)
clipped_adam = keras.optimizers.Adam(learning_rate=0.001, global_clipnorm=1.0)
```

These lines instantiate alternatives; they do not train a model on their own. Global gradient clipping rescales the combined gradient if its norm exceeds a threshold. It can limit exceptional updates, especially in sequence models. It should not be used to conceal an incorrect loss scale or non-finite arithmetic.

Adam's state means a training checkpoint is more than model weights if we want faithful continuation. Restoring weights with a fresh optimizer can change subsequent behavior. Learning-rate schedules, update counters, and random state can also matter. A checkpoint is a recovery artifact whose completeness depends on what state it captures.

## 13. Initialization, saturation, and gradient health

The sigmoid derivative is \(p(1-p)\), which becomes small when its output approaches zero or one. If many layers repeatedly multiply small derivatives, the sensitivity reaching early layers can become tiny. This is one form of vanishing gradients.

ReLU avoids saturation on its positive side but has zero derivative on its negative side. Other activations such as GELU provide different smoothness and gating behavior. No activation makes all optimization problems easy. Architecture, normalization, residual connections, initialization, and task design interact.

Variance-aware initializers choose parameter scales based on layer dimensions. Glorot-style initialization is common for balanced signal propagation in many settings; He-style initialization is often paired with ReLU. These are principled starting heuristics rather than proofs that every deep network will maintain ideal signal statistics.

Track gradient norms when diagnosing training. A gradient that is `None` means no recorded derivative path was available for that source, which differs from a valid gradient tensor filled with zeros. Zeros can arise from inactive ReLUs, multiplication by zero, or an already-flat local objective. Treating every missing gradient as zero can hide a disconnected model component.

```python
import tensorflow as tf

parameter = tf.Variable(2.0)
with tf.GradientTape() as tape:
    unrelated_loss = tf.constant(3.0)
gradient = tape.gradient(unrelated_loss, parameter)
print(gradient)  # None
```

If a trainable parameter unexpectedly produces `None`, inspect whether it participated in the forward pass, whether the pass was inside the tape, whether an intermediate left TensorFlow, and whether a discrete operation interrupted the path. Solve the structural cause before tuning optimizer settings.

## 14. Regularization changes what is optimized

A network with enough capacity can fit training peculiarities that do not generalize. One response is to add a parameter penalty. With an L2 term, an objective might be

\[
J(\theta)=L_{\text{data}}(\theta)+\lambda\sum_j\theta_j^2.
\]

The derivative gains a term \(2\lambda\theta\). This encourages smaller parameters under the chosen coefficient convention. Some texts include a factor one half in the penalty, changing the displayed derivative; always check the exact definition rather than memorizing a coefficient-free slogan.

Keras layers can attach regularization losses. A custom loop must include them in its scalar objective:

```python
import tensorflow as tf
from tensorflow import keras

model = keras.Sequential([
    keras.Input(shape=(2,)),
    keras.layers.Dense(1, kernel_regularizer=keras.regularizers.L2(0.01)),
])
features = tf.ones([4, 2])
targets = tf.zeros([4, 1])
with tf.GradientTape() as tape:
    predictions = model(features, training=True)
    data_loss = tf.reduce_mean(tf.square(predictions - targets))
    penalty = tf.add_n(model.losses) if model.losses else tf.constant(0.0)
    total_loss = data_loss + penalty
print(float(data_loss.numpy()), float(total_loss.numpy()))
```

The total objective includes both data fit and the penalty. Reporting them separately helps interpret changes. A model may have a higher total objective while improving the data term or vice versa. Comparing objectives with different regularization coefficients without separating components is usually uninformative.

Decoupled weight decay and an L2 penalty are related but not generally identical under adaptive optimizers. Weight decay directly modifies parameters as part of the update rule; an L2 penalty contributes through the gradient and can therefore be normalized by Adam's coordinate-wise mechanism. Choose deliberately when reproducing a method.

## 15. Losses, metrics, and decisions answer different questions

A training loss should provide useful derivatives. A reporting metric should summarize behavior relevant to the task. A decision policy should specify what action follows a prediction. These can be related without being identical.

Classification accuracy counts correct decisions, but small logit changes often leave the selected class unchanged. Its direct derivative is therefore not useful for ordinary gradient training. Cross-entropy responds continuously to changes in the probability assigned to the correct label. We optimize cross-entropy and can report accuracy separately.

On an imbalanced dataset, ninety-nine percent accuracy may come from predicting the majority class every time. Precision asks what fraction of predicted positives were correct. Recall asks what fraction of actual positives were found. Their denominators describe different failure costs. ROC-AUC and PR-AUC summarize ranking over thresholds, but their interpretation also depends on prevalence and evaluation design.

For a binary logit output, a probability threshold of one half corresponds to logit zero. A Keras `BinaryAccuracy` metric applied directly to logits should therefore use threshold zero. Using its default probability threshold on untransformed logits evaluates a different decision rule. Alternatively, transform logits to probabilities before updating probability-based metrics.

For regression, report units. Mean absolute error of three kilowatt-hours is interpretable; a normalized MSE of `0.08` may not be. Preserve transformation metadata so evaluation can convert predictions back to the target's original scale.

## 16. Higher-order derivatives and scientific modeling

Sometimes we need a derivative of a derivative, such as curvature or a differential-equation residual. Nested tapes can differentiate derivative computations:

```python
import tensorflow as tf

value = tf.Variable(3.0)
with tf.GradientTape() as outer:
    with tf.GradientTape() as inner:
        output = value ** 3
    first = inner.gradient(output, value)
second = outer.gradient(first, value)
print(first.numpy())   # 27.0
print(second.numpy())  # 18.0
```

The outer tape records the operations used to form the first derivative. This is more specialized than ordinary supervised training. A full Hessian for millions of parameters is too large to construct casually. Hessian-vector products and other structured techniques can sometimes answer curvature questions more economically.

Likewise, the gradient of a vector target is not automatically its full Jacobian. Calling `gradient` on a nonscalar target effectively differentiates a sum of target components under the default aggregation behavior. Use a Jacobian-specific method when individual output-to-input sensitivities are required, and reason about the potentially large resulting shape.

The practical boundary is clear: first master scalar objectives and ordinary gradients. Higher-order machinery becomes useful when the modeling objective explicitly depends on sensitivities or curvature. It should not complicate a basic classifier without a concrete reason.

## 17. A troubleshooting walk through a failed run

Suppose a network's loss becomes `NaN` after a few steps. First inspect inputs and targets for non-finite values. Then evaluate the untrained model on one batch and check its outputs. If they are already invalid, the optimizer has not yet caused the problem.

If the initial pass is finite, examine the loss calculation. A manual logarithm of a rounded zero probability is a common source. Replace fragile algebra with a stable logits-based loss where appropriate. Check target encoding and reduction scale; summing thousands of token losses can produce far larger gradients than averaging real tokens.

Next inspect gradients before updating. If they are finite but exceptionally large, reduce the learning rate and check feature scaling. Clipping can be appropriate once the objective is understood. If gradients are non-finite before the first update, identify the earliest invalid intermediate instead of repeatedly trying smaller rates.

If training remains finite but does not improve, try overfitting a tiny fixed subset with augmentation and regularization disabled. A sufficiently capable model should usually fit that deliberately simple task. Failure there points toward implementation, labels, optimization, or representation problems. Success there followed by poor validation performance points toward generalization or split issues.

This diagnostic is not permission to report tiny-subset training performance as real-world quality. It is an implementation check. Keep the purpose of each experiment explicit so an encouraging debugging result does not become misleading evidence.

## 18. What comes next

You have derived the core training mechanism: choose an objective, compute its derivative through a composed model, update parameters, and repeat using appropriate batches. You have also seen why numerical stability, label contracts, and gradient connectivity matter as much as optimizer names.

The next chapter puts these mechanics inside a reliable workflow. We will construct datasets, define Keras models, manage training and inference behavior, split data without leakage, aggregate metrics correctly, and preserve the artifacts needed to reproduce an experiment. The mathematics remains the same; the surrounding organization makes it usable on real projects.

Further reading: [automatic differentiation](https://www.tensorflow.org/guide/autodiff), [Keras losses](https://keras.io/api/losses/), [optimizers](https://keras.io/api/optimizers/), and [custom TensorFlow training loops](https://keras.io/guides/writing_a_custom_training_loop_in_tensorflow/). Use these references to check exact API contracts while retaining the mathematical reasoning developed here.

## Extended study — Likelihood, uncertainty, and the geometry of updates

### Conditional probability clarifies what the classifier estimates

A classifier estimates a relationship like probability of a label given observed features. It does not usually model the full process that generated the features themselves. Conditioning restricts the question to examples with the supplied information. If a crucial variable is missing, the best achievable prediction can still be uncertain.

Bayes' rule relates conditional probabilities through joint probability. In a binary setting, posterior odds equal prior odds multiplied by a likelihood ratio. This helps explain why class prevalence matters. A screening system deployed where positives are rare can have low precision even if its true-positive and false-positive rates look favorable.

Suppose one percent of examples are positive. A classifier catches ninety percent of positives and falsely flags five percent of negatives. Among ten thousand examples, that yields about ninety true positives and four hundred ninety-five false positives. Precision is ninety divided by five hundred eighty-five, approximately fifteen percent. The arithmetic connects a probability model to operational workload.

This does not mean accuracy or recall is useless. It means the evaluation must reflect the deployment population and decision cost. A probability threshold selected on a balanced development sample may need reconsideration when the real population has a different prevalence. Changes in conditional relationships are more complex than a simple prior adjustment and require fresh validation.

### Maximum likelihood and a parameter prior

Minimizing negative log likelihood chooses parameters that make observed targets probable under a model. Adding a negative log prior yields a maximum a posteriori objective. A zero-centered Gaussian prior over parameters produces a quadratic penalty up to constants and scaling.

This interpretation is useful for understanding L2 regularization, but it does not make an ordinary trained network a complete Bayesian posterior. A point estimate still selects one parameter configuration. Representing uncertainty over parameters requires additional methods and assumptions.

Aleatoric uncertainty refers to variation inherent in the modeled observations, such as noisy labels or measurements. Epistemic uncertainty concerns what the model does not know because data or modeling knowledge is limited. These categories can interact in practice. A single softmax confidence does not reliably separate them.

Deep ensembles train several models and examine their predictions collectively. Monte Carlo dropout keeps dropout active across repeated inference passes under a particular approximate uncertainty interpretation. Both require evaluation rather than assuming disagreement is perfectly calibrated uncertainty. A model family can confidently share the same blind spot.

### Curvature explains learning-rate sensitivity

For the one-dimensional quadratic `L(w) = a * (w - w_star)^2 / 2`, the derivative is `a * (w - w_star)`. Gradient descent updates the error by multiplying it by `1 - learning_rate * a` at each step. For positive curvature, convergence requires the multiplier's magnitude to be below one.

Thus a learning rate between zero and `2 / a` converges for this exact quadratic. A rate below `1 / a` approaches without alternating sign; a larger stable rate can oscillate while shrinking. At or beyond the boundary, the error fails to shrink. This is a concrete demonstration of why a large gradient does not justify an arbitrarily large update.

In several dimensions, different directions can have different curvature. A narrow curved valley can require small steps across its steep direction while making slow progress along its shallow direction. Feature scaling, momentum, and adaptive methods can help, but a neural network's nonconvex landscape is more complicated than one fixed quadratic.

### Schedules change the update rule over time

A learning-rate schedule can take larger exploratory steps early and smaller steps later. Warmup starts with smaller rates before reaching the intended operating scale. Decay reduces rates according to steps, epochs, or validation behavior. These are choices about optimization dynamics, not substitutes for a correct objective.

```python
from tensorflow import keras

schedule = keras.optimizers.schedules.ExponentialDecay(
    initial_learning_rate=0.01,
    decay_steps=100,
    decay_rate=0.9,
    staircase=True,
)
optimizer = keras.optimizers.SGD(learning_rate=schedule, momentum=0.9)
print(float(schedule(0).numpy()))
print(float(schedule(100).numpy()))
```

The schedule is indexed by optimizer steps. Changing batch size changes the number of steps per epoch, so the same schedule parameters may represent a different amount of data exposure. Record the unit of every scheduling quantity. A schedule described vaguely as decaying every hundred can otherwise be impossible to reproduce.

When comparing optimizers, tune reasonable learning rates for each rather than giving them identical numbers and declaring the winner universal. Also compare validation behavior, training time, and sensitivity across seeds. One favorable run is evidence about one configuration, not a law about all neural networks.
