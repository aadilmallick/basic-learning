# TensorFlow 2 from first principles

A complete five-chapter Markdown course connecting TensorFlow programming, neural network mathematics, model architecture, and reliable engineering. Each chapter contains more than 5,000 whitespace-separated words and is designed for several slow study sessions. This is a core-to-advanced practical course, not an exhaustive catalog of every TensorFlow ecosystem API.

The course uses [Aman's TensorFlow primer](https://aman.ai/primers/tensorflow/) as its coverage starting point. Its historical TensorFlow 1 patterns are translated into TensorFlow 2 and Keras 3. Mathematical derivations and expanded lessons are original instructional material. See [sources and compatibility](SOURCES.md), [source coverage](SOURCE-COVERAGE.md), and [validation evidence](VALIDATION.md).

## Prerequisites and approach

Assume ordinary Python familiarity: functions, classes, imports, arrays, and loops. Tensor notation, matrix operations, differentiation, probability outputs, and optimization are taught where needed. A CPU is sufficient for the examples. Python 3.11 with TensorFlow 2.20.0 is the selected reference environment; it is not described as the latest release.

Read in order. Follow a small example, inspect its shapes, then connect the formula to the corresponding operation. Pause between numbered sections. Extended study sections deepen the same chapter after the central path; they can be read on a second pass. Optional applications are provided without mandatory quizzes or recall gates.

## Curriculum and reading order

| Chapter | Study sequence | What you should be able to do afterward |
| --- | --- | --- |
| [1. Tensors and mathematical foundations](lessons/01-foundations-tensors-and-neural-network-math.md) | Setup → shapes and dtypes → broadcasting → dot products and matrices → scaling → neural forward passes → probability outputs → geometry | Trace a prediction from raw numbers through a network and explain every axis and operation |
| [2. Derivatives, losses, and optimization](lessons/02-autodiff-losses-and-optimization.md) | Squared error → derivatives → chain rule → GradientTape → dense-layer backpropagation → likelihood losses → minibatches → optimizers → regularization → uncertainty | Derive a training update, choose a coherent loss, and diagnose broken or unstable gradients |
| [3. Keras, data, and experiments](lessons/03-keras-data-and-reliable-experiments.md) | Splits → model APIs → preprocessing → fit and callbacks → datasets → image/text pipelines → masks → records → metrics → structured inputs | Build a repeatable training experiment without common leakage, masking, or metric errors |
| [4. Architectures and generative objectives](lessons/04-vision-sequences-attention-and-generative-models.md) | Convolution → transfer and residuals → embeddings → recurrence → sequence losses → attention → transformers → generation → autoencoders and VAE | Explain architectural assumptions and implement small vision, sequence, attention, and reconstruction computations |
| [5. Advanced execution and delivery](lessons/05-graphs-custom-training-and-deployment.md) | Custom layers → mode behavior → custom loops → graphs → profiling → precision → distribution → saving → serving → edge conversion → operations | Extend training safely, reason about performance, and produce an explicit reloadable inference artifact |

## Install and run

From this folder on Linux, macOS, or WSL:

```bash
python3.11 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
python examples/math_lab.py
python examples/pipeline_demo.py
python examples/tabular_capstone.py
python examples/attention_demo.py
python examples/custom_loop.py
```

PowerShell environment activation is `.\.venv\Scripts\Activate.ps1`; see Chapter 1 for full setup. For modern NVIDIA GPU support on Windows, consult the official WSL2 instructions. Learn on CPU first if accelerator setup would delay the course.

All five standalone examples use generated local data, so no external datasets or pretrained weights are required. Installation still needs a package source with the required dependencies. The capstone writes to `artifacts/tabular` by default; passing the same output path can replace previous output files. Use distinct output folders when comparing experiments.

| Example | Purpose | Evidence available in this delivery |
| --- | --- | --- |
| [math_lab.py](examples/math_lab.py) | Forward values and analytic gradient assertions | Python syntax checked; TensorFlow execution not available here |
| [pipeline_demo.py](examples/pipeline_demo.py) | Create/decode image, vectorize text, parse a record | Python syntax checked; TensorFlow execution not available here |
| [tabular_capstone.py](examples/tabular_capstone.py) | Split, normalize, train, evaluate, save, reload | Python syntax checked; TensorFlow execution not available here |
| [attention_demo.py](examples/attention_demo.py) | Positions, causal/padding masks, shifted loss, causal parity assertion | Python syntax checked; TensorFlow execution not available here |
| [custom_loop.py](examples/custom_loop.py) | Compiled training step and correct epoch aggregation | Python syntax checked; TensorFlow execution not available here |

To also export the trained tabular model:

```bash
python examples/tabular_capstone.py --output artifacts/export_run --export
```

Inline Python blocks are standalone unless marked as integration blocks or fragments. An integration block intentionally uses variables from the preceding section. Shape-only examples are labeled as such; they are not claims of useful trained model quality.

## Verification and GitHub use

Run the package checks with:

```bash
python tools/validate_curriculum.py
python tools/verify_math.py
```

The first script uses only the standard library. The second uses NumPy to independently verify selected hand calculations. Neither executes TensorFlow. Full TensorFlow example execution remains a documented follow-up check in an installed environment, not something claimed to have passed here.

Unzip the download, copy this entire folder into a repository, and commit the Markdown, examples, requirements, and tools together. There is no absolute-path dependency in the course. Generated training artifacts and virtual environments should remain outside source control. A suggested `.gitignore` is included.

After successful installation, record your actual environment with `python -m pip freeze > environment.lock.txt`. The provided requirements are top-level constraints rather than a complete cross-platform lock. Review new TensorFlow/Keras migration notes when changing versions, especially custom training, serialization, and edge conversion behavior.
