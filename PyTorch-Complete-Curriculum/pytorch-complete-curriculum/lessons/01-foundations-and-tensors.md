# 1. From numbers to tensors: the language of neural networks

[Course index](../README.md) · [Next: gradients and neural networks](02-gradients-and-neural-networks.md)

## How to study this chapter

This chapter starts at the beginning of the numerical ideas that make PyTorch useful. You need basic programming experience, but you do not need previous machine learning experience. Read one section at a time. The short programs are independent unless a section explicitly calls a block a continuation. There is no requirement to memorize method names. The useful skill is learning to describe the quantities in a calculation and then choosing operations that preserve that meaning.

By the end, you will understand what a tensor represents, how its shape describes a learning problem, how matrix multiplication builds a prediction, why broadcasting sometimes introduces silent bugs, and how data type, device, and memory sharing affect code. These are not preliminary inconveniences before the interesting material. Most difficult neural network bugs involve these exact ideas, merely inside larger programs.

The recurring task will be predicting a continuous quantity from measurements. Imagine estimating energy consumption from floor area and outdoor temperature. Later chapters use classification, images, and text, but the same numerical contracts remain. We begin with a model simple enough to calculate by hand so that the framework never becomes a substitute for understanding.

## 1.1 What a machine learning framework actually does

Suppose a conventional program estimates consumption using a formula written by an engineer. It might multiply area by a coefficient, adjust for temperature, and add a baseline. Machine learning keeps the idea of a numerical formula but obtains some of its coefficients from examples. An example consists of inputs and, in supervised learning, an observed answer. The program searches for coefficients that make its predictions agree with those observations according to an explicitly chosen error measure.

A framework helps with three jobs. First, it represents large collections of numbers and computes with them efficiently. Second, it tracks how numerical computations depend on adjustable quantities and calculates derivatives. Third, it provides reusable components for models, optimization, data loading, and related engineering. None of these jobs determines whether the dataset represents the real world, whether a target is appropriate, or whether a prediction should be trusted. Those remain modeling and evaluation questions.

The word *training* means repeatedly computing predictions, measuring their errors, and adjusting parameters. The word *inference* means using a fitted model to compute predictions on inputs. A parameter is an adjustable numerical value stored by the model. A hyperparameter is a choice about the learning procedure or architecture, such as learning rate or hidden width. The distinction concerns how a value is selected, not whether it is a number.

A neural network is a parameterized function built by composing relatively simple functions. Its size does not remove the need to understand those components. A model with millions of parameters still uses multiplication, addition, nonlinear functions, and reductions. Our first objective is to read those calculations without losing track of what each axis means.

## 1.2 A working environment with a clear identity

Use a supported Python version from the official [installation selector](https://pytorch.org/get-started/locally/). Create an isolated environment before installing packages. Isolation prevents another project's dependencies from changing the behavior of your learning environment. On Windows PowerShell, a typical beginning is:

```powershell
py -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
```

On Linux or macOS, the corresponding beginning is:

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
```

Then run the installation command selected for your actual operating system and compute platform. For a CPU learning environment, the selector offers a CPU route. Do not copy a random CUDA command merely because a tutorial used it. CUDA wheels, GPU drivers, operating systems, and supported Python versions must agree. The small programs in the foundational chapters work on CPU; a GPU is an optional accelerator, not a conceptual prerequisite.

After installation, run this complete diagnostic program:

```python
import platform
import sys
import torch

print('Python:', sys.version.split()[0])
print('Executable:', sys.executable)
print('Platform:', platform.platform())
print('PyTorch:', torch.__version__)
print('CUDA available:', torch.cuda.is_available())
print(torch.tensor([1.0, 2.0]) + 3)
```

The final line should display values equivalent to `tensor([4., 5.])`. A false CUDA result does not mean PyTorch is broken. It means that this process does not currently have a usable CUDA backend. On a supported Apple machine, MPS is a different backend; CUDA availability is not its availability check. Record the printed environment when reporting problems. The Python executable is particularly useful when a notebook imports a different installation from the terminal.

This course was researched on November 12, 2026. The official pages consulted exposed PyTorch 2.15 documentation alongside some cached 2.14 results. The examples use established PyTorch 2.x interfaces rather than assuming that every advanced backend supports every release. See the source register and validation report for the difference between documented APIs and execution performed while preparing the course.

## 1.3 The Python features we actually need

A tensor program is still a Python program. A function receives arguments and returns an object. A class groups state and behavior. A list holds an ordered collection. A dictionary maps keys to values. A loop repeats a calculation. These familiar ideas will organize models and training loops, so let us connect them to a numerical example before adding framework abstractions.

```python
def estimate_consumption(area, rate, baseline):
    return area * rate + baseline

measurements = [20.0, 40.0, 60.0]
configuration = {'rate': 2.0, 'baseline': 5.0}

for area in measurements:
    prediction = estimate_consumption(
        area,
        configuration['rate'],
        configuration['baseline'],
    )
    print(prediction)
```

This prints `45.0`, `85.0`, and `125.0`. The function specifies one calculation. The loop applies it to three observations. The dictionary stores values chosen by us. Later, the rate and baseline will be learned parameters, and a tensor operation will replace the explicit example loop. The mathematical calculation remains recognizable.

Python objects may refer to the same mutable data. Assignment usually binds another name; it does not necessarily make a copy. If two variables refer to a list and one changes its first element, both names observe the change. Tensor views have a related behavior, although shape and strides add another layer. Remember this connection when a model's saved weights seem to change after more training.

A context manager, written with `with`, temporarily changes behavior inside a block and restores the surrounding context afterward. We will use this syntax for disabling gradient recording and selecting mixed precision. A decorator such as `@torch.no_grad()` applies a wrapper to a function. You need not understand decorators deeply yet; recognize that the wrapper changes how calls to that function execute.

## 1.4 Scalars, vectors, matrices, and higher dimensions

A scalar is one number. A vector is an ordered collection of numbers. A matrix is a rectangular arrangement with two axes. A tensor generalizes these arrangements to any number of axes. In PyTorch, a scalar can be a zero-dimensional tensor, a vector a one-dimensional tensor, and a matrix a two-dimensional tensor. The term *rank* in this programming context commonly means the number of axes; matrix rank in linear algebra is a different concept.

```python
import torch

baseline = torch.tensor(5.0)
areas = torch.tensor([20.0, 40.0, 60.0])
features = torch.tensor([
    [20.0, 10.0],
    [40.0, 15.0],
    [60.0, 20.0],
])

for name, value in [('baseline', baseline), ('areas', areas),
                    ('features', features)]:
    print(name, value.shape, value.ndim, value.numel())
```

The shapes are `[]`, `[3]`, and `[3, 2]`. Their numbers of axes are zero, one, and two. Their element counts are one, three, and six. `shape` describes axis sizes. `ndim` counts axes. `numel()` counts stored elements in the logical tensor. These answer different questions, so avoid using the word *size* without clarifying which one you mean.

Our feature matrix uses rows for examples and columns for measurements. Its first column is area and its second column is temperature. That interpretation is a convention established by our program. PyTorch sees only a rectangular collection of values. It cannot determine whether you accidentally swapped temperature and area while loading a file. Shape correctness is necessary, but semantic correctness requires an explicit feature order.

A batch of images often has shape `[B, C, H, W]`: batch, channels, height, and width. A batch of embedded text often has shape `[B, T, D]`: batch, token positions, and embedding features. These letters are documentation conventions, not special Python variables. Writing them beside a function is a practical way to explain its input contract.

## 1.5 A tensor has more than values

Four properties deserve attention whenever you create a tensor: values, shape, data type, and device. A fifth property, gradient participation, becomes central in the next chapter. Values tell us what was measured. Shape tells us how observations are organized. Data type controls how values are represented and which operations make sense. Device tells us where computations and storage live.

```python
import torch

measurements = torch.tensor([[2.0, 3.0], [4.0, 5.0]],
                            dtype=torch.float32,
                            device='cpu')
class_ids = torch.tensor([0, 2], dtype=torch.long)

print(measurements.dtype, measurements.device)
print(class_ids.dtype, class_ids.device)
```

`float32` is a common starting type for measurements and model weights. `long` is PyTorch's signed 64-bit integer type, commonly used for class identifiers and embedding indices. A class identifier of two is a category address, not a continuous measurement that should receive a small gradient update. This is why integer targets and floating-point inputs have different roles.

Floating-point arithmetic approximates real arithmetic. Many decimal fractions cannot be represented exactly in a finite binary format. Consequently, mathematically equivalent rearrangements can differ slightly in their results. Compare floating-point computations using tolerances appropriate to the problem, such as `torch.allclose`, rather than requiring exact equality in every situation. Tolerance does not excuse large errors; it acknowledges the representation used.

Do not create a random integer tensor and request ordinary gradients through its entries. Optimization over continuous model parameters relies on local changes in real-valued quantities. Discrete selections may be part of a differentiable model, but differentiation then follows the continuous values selected or uses a separate estimator. Chapter 6 develops that distinction through distributions and policy gradients.

## 1.6 Creating useful numerical objects

The creation functions express different intentions. `zeros` starts with zero values. `ones` starts with one values. `arange` creates regularly spaced values with an exclusive stopping boundary. `linspace` creates a specified number of points including both endpoints. `randn` samples a standard normal distribution. `empty` allocates uninitialized memory and must be filled before its values are interpreted.

```python
import torch

torch.manual_seed(7)
print(torch.zeros(2, 3))
print(torch.ones(2))
print(torch.arange(0, 6, 2))
print(torch.linspace(0.0, 1.0, steps=5))
print(torch.randn(2, 2).shape)
```

The integer sequence is `[0, 2, 4]`. The evenly spaced floating-point values are approximately `[0.0, 0.25, 0.5, 0.75, 1.0]`. The random matrix has shape `[2, 2]`. A seed selects a reproducible sequence within a particular execution setting; it does not guarantee identical floating-point results across every device, version, and parallel configuration.

Normal random samples will later initialize weights and simulate noise. A normal distribution has a bell-shaped density described by a mean and standard deviation. Standard normal means mean zero and variance one. Variance measures average squared distance from the mean; standard deviation is its square root and has the original quantity's units. We will distinguish population and sample estimators when normalizing training data.

Prefer explicit dtypes when the meaning matters. For example, `torch.tensor([1, 2])` ordinarily creates integers, while `torch.tensor([1.0, 2.0])` creates floating-point values. An unnoticed difference can surface much later as a matrix multiplication error. Factories such as `zeros_like(existing)` are useful when a new tensor should inherit another tensor's shape and related properties.

## 1.7 Elementwise operations and the first prediction

An elementwise operation applies the same scalar rule at corresponding positions. Multiplying an area vector by a scalar rate multiplies each area's value. Adding a baseline then adds that number to each prediction. The framework processes the collection without a Python loop over individual observations.

```python
import torch

areas = torch.tensor([20.0, 40.0, 60.0])
rate = torch.tensor(2.0)
baseline = torch.tensor(5.0)
predictions = areas * rate + baseline
print(predictions)
```

The result is `[45, 85, 125]` in floating-point form. This is vectorization: expressing a collection of related calculations as tensor operations. It often improves performance because optimized numerical kernels process many values together. More importantly at this stage, it lets the written calculation closely resemble the mathematical formula.

Do not confuse elementwise multiplication with matrix multiplication. `left * right` multiplies corresponding entries after broadcasting rules are applied. `left @ right` contracts a shared dimension according to matrix multiplication rules. Both are useful, but they encode different mathematical questions. If the operation is combining several features into one score, a dot product or matrix multiplication is usually involved.

Operators also follow precedence rules. Multiplication happens before addition in the expression above. Parentheses can make intended grouping explicit, especially for normalization and loss formulas. An expression such as `values - mean / scale` does not mean `(values - mean) / scale`. Small syntax differences can change the underlying model while leaving the code perfectly executable.

## 1.8 Dot products: a weighted combination of evidence

For two vectors with matching length, the dot product multiplies corresponding entries and adds the products. If features are `[area, temperature]` and weights are `[area_weight, temperature_weight]`, their dot product is one prediction before adding the baseline. Each coefficient expresses how a measurement contributes within this particular model.

For features `[20, 10]` and weights `[2, -1]`, the dot product is `20 × 2 + 10 × (-1) = 30`. Adding baseline five produces thirty-five. The negative temperature coefficient means that, while holding the area input fixed, a larger temperature reduces the predicted consumption. This is a statement about the fitted formula; it is not automatically a causal conclusion about buildings.

```python
import torch

features = torch.tensor([20.0, 10.0])
weights = torch.tensor([2.0, -1.0])
prediction = torch.dot(features, weights) + 5.0
print(prediction.item())
```

`item()` extracts a Python number from a tensor containing exactly one element. That is convenient for reporting. It is unsuitable when you intend to preserve a differentiable computation, because a Python float does not carry the tensor's autograd connection. This is a first example of an operation that is harmless for logging and harmful inside a loss calculation.

The geometric interpretation of a dot product connects alignment and magnitude. For nonzero vectors, their dot product equals the product of their lengths multiplied by the cosine of the angle between them. A larger positive dot product can indicate aligned directions. In learned models, vector scales also matter, so a large dot product should not casually be called pure similarity without discussing normalization.

## 1.9 Matrix multiplication handles a whole batch

Place examples in the rows of a matrix `X` with shape `[B, F]`, where `B` is the number of examples and `F` the number of features. Multiply by a weight vector with shape `[F]`. The result has shape `[B]`, one weighted sum per example. Each row performs exactly the dot product we just calculated.

```python
import torch

features = torch.tensor([[20.0, 10.0],
                         [40.0, 15.0],
                         [60.0, 20.0]])
weights = torch.tensor([2.0, -1.0])
predictions = features @ weights + 5.0
print(predictions)
```

The three predictions are thirty-five, seventy, and one hundred five. The inner feature dimension disappears because it is summed over. This operation is called a contraction. When a formula appears complicated, identify which axes remain and which axes are summed away. That habit scales directly to convolution, attention, and per-example gradients.

For several output features, use a weight matrix. If `W` has shape `[F, O]`, then `X @ W` has shape `[B, O]`. Every output column uses its own weight vector. Later, `nn.Linear(F, O)` stores its weight internally as `[O, F]` and computes the equivalent `X @ weight.T + bias`. The transpose is an implementation convention, not a different model.

Matrix multiplication is not commutative. Even when both orders are shape-compatible, `A @ B` generally differs from `B @ A`. Swapping operands because an error disappears is not debugging. Write the intended scalar sum, assign meanings to indices, and recover the correct tensor expression from that description.

## 1.10 Reductions: removing an axis by answering a question

A reduction combines values along an axis. A sum asks for a total. A mean asks for an average. A maximum asks for the largest value. Reductions matter because training usually begins with many prediction errors and ends with one scalar objective. Before reducing, specify which observations should have equal influence.

```python
import torch

values = torch.tensor([[1.0, 3.0], [5.0, 7.0]])
print(values.mean())
print(values.mean(dim=0))
print(values.mean(dim=1))
print(values.mean(dim=1, keepdim=True))
```

The overall mean is four. Reducing dimension zero averages corresponding columns across examples and produces `[3, 5]`. Reducing dimension one averages features within each example and produces `[2, 6]`. Keeping the reduced dimension produces shape `[2, 1]`, preserving the place of the axis for a later broadcast.

A useful verbal rule is that `dim` names the axis being combined, not the axis being kept. If rows are examples and columns are features, `mean(dim=0)` computes one mean per feature. This is exactly what a standardization transform usually needs. `mean(dim=1)` answers a different question: the average value within each observation.

For a maximum, you may need both the value and its location. `values.max(dim=1)` returns both. `argmax(dim=1)` returns only the index of the largest entry along that axis. In classification, that index can be a predicted class. It is not a probability, and it is not normally part of the differentiable training objective.

## 1.11 Broadcasting, with a silent failure example

Broadcasting permits operations between certain different shapes. Compare axes from the right. Two sizes are compatible if equal or if one is one. Missing leading axes behave as singleton axes. A singleton dimension can be logically repeated to match the other operand. This usually avoids explicitly allocating repeated copies.

Consider a matrix `[B, F]` and a feature mean vector `[F]`. Their trailing dimensions match, so subtraction removes the corresponding feature mean from every row. A per-example mean `[B]` does not generally align with `[B, F]`; it lines up against the feature dimension. Keeping it as `[B, 1]` communicates the correct intention.

```python
import torch

predictions = torch.tensor([[1.0], [2.0], [3.0]])
targets = torch.tensor([1.0, 2.0, 3.0])
wrong_errors = predictions - targets
right_errors = predictions.squeeze(-1) - targets
print(wrong_errors.shape)
print(right_errors.shape)
print(right_errors)
```

The wrong shape is `[3, 3]`. Every prediction is compared with every target. The right shape is `[3]`, and all errors are zero. Both expressions execute. This is why assertions about expected shapes are useful even when no exception is raised. A training loop can optimize an unintended objective for hours without producing a runtime error.

Use `squeeze(-1)` when you deliberately remove a final singleton output axis. An unrestricted `squeeze()` can also remove the batch axis when batch size is one. Programs that work for large batches and fail on the last batch often have this exact mistake. Preserve the batch contract explicitly rather than relying on accidental dimensions.

## 1.12 Indexing, masks, and discrete choices

Indexing selects values. A scalar index selects one position. A slice selects a range. A Boolean mask selects positions for which a condition is true. These operations have different output shapes, so inspect shape and meaning together. For a feature matrix, `features[:, 0]` selects the first feature for all examples and usually removes that feature axis.

```python
import torch

features = torch.tensor([[20.0, 10.0],
                         [40.0, 15.0],
                         [60.0, 20.0]])
areas = features[:, 0]
large = areas >= 40.0
print(areas)
print(large)
print(features[large])
```

The mask contains false, true, true. Applying it selects the final two rows. Masks are important for missing labels, padding tokens, sequence boundaries, and selective metrics. They are discrete decisions. Gradients can flow through the selected floating-point values, but ordinary differentiation does not tell you how to change a Boolean condition continuously.

A mask used in a loss also defines a denominator. If only three of ten positions are valid, averaging all ten after zeroing invalid losses underweights the example relative to a mean over the three valid positions. Define whether the objective should weight examples, tokens, or something else equally. This apparently minor reduction choice becomes important in variable-length sequence training.

## 1.13 Shape changes are not all the same operation

`reshape` changes how a sequence of elements is grouped into axes. `transpose` exchanges two axes. `permute` reorders all axes. These may produce the same output shape while arranging values differently. Shape equality does not prove computational equivalence.

```python
import torch

values = torch.tensor([[1, 2, 3], [4, 5, 6]])
print(values.reshape(3, 2))
print(values.transpose(0, 1))
```

Reshaping produces rows `[1, 2]`, `[3, 4]`, `[5, 6]`. Transposing produces rows `[1, 4]`, `[2, 5]`, `[3, 6]`. The first regrouped elements in their logical traversal order. The second exchanged the row and column interpretations. Converting an image from height-width-channel to channel-height-width requires axis permutation, not an arbitrary reshape.

`unsqueeze` inserts a singleton axis. `squeeze` removes singleton axes. `stack` creates a new axis while joining tensors. `cat` joins along an existing axis. If you have several vectors representing examples, stacking them creates a batch matrix. If you already have several batch matrices with the same feature width, concatenating them along axis zero creates a larger batch.

An inferred dimension of `-1` asks PyTorch to calculate one axis size from the total number of elements. It does not grant permission to change the element count. You may infer only one dimension in a reshape because the total alone cannot determine multiple unknown sizes. Treat inferred dimensions as a convenience after you understand the intended contract.

## 1.14 Views, storage, and copying

A view is another tensor interpretation sharing underlying storage. Changing a view can therefore change the original. Some shape transformations return views; others may require copies. `reshape` can choose either according to layout. `view` requires compatible strides. A contiguous tensor is sufficient for many reshapes, but saying that every noncontiguous tensor categorically cannot be viewed is too strong.

```python
import torch

original = torch.arange(6.0).reshape(2, 3)
shared = original[:, :2]
independent = shared.clone()
shared[0, 0] = 99.0
print(original[0, 0].item())
print(independent[0, 0].item())
```

The original now contains ninety-nine at that position; the clone retains zero. `clone()` makes a copy of values. It does not, by itself, sever a gradient connection. `detach()` severs that connection but ordinarily still shares storage. If you need both independence and no gradient history, use `detach().clone()`.

Strides describe how logical index changes map to storage offsets. You do not need to calculate strides for everyday model construction, but they explain why a transposed tensor can have the expected shape and still reject a particular `view`. Start with `reshape` when regrouping is your intention, and use `contiguous()` only when a particular layout is actually required.

Avoid in-place changes to tensors needed for gradient computation until you understand their lifetime. Operations with a trailing underscore, such as `add_`, usually modify their input. In-place code can save an allocation but can also overwrite a value the backward pass needs. Correctness comes before such micro-optimizations.

## 1.15 Device movement and interoperability

A tensor on CPU and a tensor on GPU generally cannot participate directly in the same arithmetic operation. Move related tensors to the same device. Moving a tensor returns a tensor on the destination; bind the result if you need to retain it. Moving a module has different object-level behavior, which we discuss when constructing models.

```python
import torch

device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
features = torch.tensor([[1.0, 2.0]], device=device)
weights = torch.tensor([3.0, 4.0], device=device)
result = features @ weights
print(result.detach().cpu().tolist())
```

The value is eleven, regardless of whether the chosen device is CPU or CUDA. Device selection should be centralized rather than scattered through a program. When diagnosing a mismatch, print the device of the inputs, parameters, targets, and newly created helper tensors. A mask or position index created without a device argument is a common hidden CPU tensor.

NumPy interoperability is useful for plotting and scientific libraries. A CPU tensor with suitable layout and dtype can often share memory with a NumPy array. `tensor.detach().cpu().numpy()` is the familiar conversion path for ordinary dense outputs. Neither this conversion nor `item()` belongs in a differentiable model path that must preserve autograd history.

A GPU operation may execute asynchronously relative to the Python process. Converting a GPU scalar to a Python number can force synchronization. That is irrelevant for our tiny examples but matters when logging every batch of a large training job. Later performance work will measure complete workloads rather than assuming that a short Python timer captures completed GPU work.

## 1.16 Standardization as a complete mathematical application

Suppose area values range in the hundreds and temperature values in the tens. A model can still express a correct formula, but optimization may behave awkwardly because different parameter directions have very different numerical scales. Standardization transforms each feature by subtracting a training mean and dividing by a training scale.

For feature index `j`, write the transform as

\[
z_{ij}=\frac{x_{ij}-\mu_j}{\max(\sigma_j,\epsilon)}.
\]

Here `i` identifies an example, `j` identifies a feature, and epsilon is a small positive safeguard. A constant feature has zero standard deviation, so direct division would fail. The clamp handles the arithmetic; it does not make that feature informative.

```python
import torch

training = torch.tensor([[20.0, 10.0],
                         [40.0, 15.0],
                         [60.0, 20.0]])
validation = torch.tensor([[50.0, 12.0]])
mean = training.mean(dim=0, keepdim=True)
scale = training.std(dim=0, correction=0, keepdim=True).clamp_min(1e-6)
training_z = (training - mean) / scale
validation_z = (validation - mean) / scale
print(training_z.mean(dim=0))
print(validation_z.shape)
```

The training means after transformation are approximately zero. `correction=0` selects the population-style average squared deviation for this transform. `keepdim=True` yields `[1, F]` statistics that broadcast clearly over examples. The validation set uses the training statistics. Recomputing a separate mean on validation would give different feature semantics and allow evaluation data to influence preprocessing.

This is our first example of a learned preprocessing artifact. Although it is not a neural network weight, the mean and scale were estimated from training observations. They must travel with the fitted model. If deployment subtracts a different mean, it supplies inputs in a coordinate system the model did not learn.

## 1.17 A numerical error measure before optimization

A model needs an objective that translates predictions into a scalar preference. For continuous regression, a common objective is mean squared error:

\[
L=\frac{1}{B}\sum_{i=1}^{B}(\hat y_i-y_i)^2.
\]

The hat means prediction. Subtracting gives a signed error. Squaring makes positive and negative errors contribute positively and increases the influence of large errors. Averaging keeps the typical scale more comparable across batch sizes. This objective is a choice: if extreme errors should have less influence, a robust alternative might be appropriate.

```python
import torch

predictions = torch.tensor([3.0, 5.0, 7.0])
targets = torch.tensor([2.0, 5.0, 9.0])
errors = predictions - targets
loss = errors.square().mean()
print(errors)
print(loss.item())
```

The errors are one, zero, and negative two. Their squares are one, zero, and four. The average is five thirds. The result is one number because optimization needs a scalar objective in this basic setting. Its units are squared target units, so it should not be casually described as an average error in the original unit.

A loss of zero on these three examples means exact agreement there. It says nothing by itself about unseen observations. It also says nothing about whether the targets were correctly recorded. Distinguish numerical fit, generalization, and problem validity from the beginning. Later chapters build an evaluation process that addresses these different questions separately.

## 1.18 Reading errors as violated contracts

When matrix multiplication complains about incompatible shapes, translate the message into a contract. A `[B, F]` input needs a matching feature dimension in the weights. When cross-device arithmetic fails, inspect placement. When an integer cannot require gradients, inspect the role of the quantity. This turns debugging into checking a small number of invariants rather than changing random lines.

Sometimes the most dangerous error is the absence of an exception. Broadcasting an output `[B, 1]` against targets `[B]`, swapping feature columns, and applying a validation transform fitted on validation can all run successfully. A disciplined numerical program checks not only that operations are legal, but that their results answer the intended question.

Use tiny deterministic examples when a large model becomes confusing. Replace a thousand examples with two and random values with small distinct integers. A reshape error is easier to see in a matrix containing one through six than in a screen full of random decimals. The same debugging method will later expose attention masks and padding mistakes.

## 1.19 Optional application: a transparent prediction report

Here is a complete program combining the chapter's ideas. It does not train anything yet. It calculates predictions from chosen coefficients, checks shapes, and reports an interpretable error. The deliberate simplicity makes every stage inspectable.

```python
import torch

features = torch.tensor([[20.0, 10.0],
                         [40.0, 15.0],
                         [60.0, 20.0]])
targets = torch.tensor([36.0, 69.0, 107.0])
weights = torch.tensor([2.0, -1.0])
bias = torch.tensor(5.0)

assert features.ndim == 2
assert features.shape[1] == weights.shape[0]
predictions = features @ weights + bias
assert predictions.shape == targets.shape
squared_errors = (predictions - targets).square()

for measured, predicted, error in zip(
        targets.tolist(), predictions.tolist(), squared_errors.tolist()):
    print(f'observed={measured:.1f}, predicted={predicted:.1f}, squared={error:.1f}')
print('MSE:', squared_errors.mean().item())
```

The squared errors are one, one, and four, giving mean squared error two. We can trace those values back to the formula instead of trusting a mysterious score. The next chapter replaces our chosen coefficients with adjustable tensors and derives the rule used to improve them. All of the shape, dtype, and semantic contracts established here remain in force.

### A practical boundary for this foundation

You do not need to become fast at mental matrix arithmetic before continuing. The purpose of the small calculations is to establish a reliable interpretation of the program. When a tensor has shape `[12, 7]`, you should be able to say what the twelve positions mean and what the seven positions mean. When an operation removes an axis, you should be able to say what was combined. When a transformation changes the units, you should know which statistics define the new coordinate system.

This habit also improves collaboration. A function documented as accepting “some input tensor” leaves important assumptions unstated. A function documented as accepting floating-point standardized features with shape `[batch, features]`, in a named feature order, on the model's device, gives the next reader a concrete contract. The extra precision prevents mistakes before they become numerical mysteries. In the remaining chapters, treat these contracts as part of the model definition itself, together with its equations and learned parameters.

## Sources and continuation

This chapter's instruction and numerical examples are original. The supplied [Aman PyTorch primer](https://aman.ai/primers/pytorch/) motivated coverage of tensor manipulation and its place in a full learning pipeline. Consult the official [PyTorch basics](https://docs.pytorch.org/tutorials/beginner/basics/intro.html), [installation selector](https://pytorch.org/get-started/locally/), and [reproducibility notes](https://docs.pytorch.org/docs/2.15/notes/randomness.html) for the applicable environment and API contracts. Accessed November 12, 2026.
