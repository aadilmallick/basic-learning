# Validation report

Prepared November 12, 2026. The final measured results are included below and in `validation-results.json`.

## What was verified

- Seven finished lessons, with prerequisite-first navigation and original worked examples.
- Each lesson contains at least 5,000 whitespace-separated words using Python `str.split()`.
- Every Python lesson block and every supplied Python file parses successfully with Python's AST parser.
- Markdown fences are paired; relative file links and heading anchors resolve.
- No TODO, TBD, or FIXME markers remain in lesson content.
- Two Python-only calculus programs were actually executed.
- Independent arithmetic checks verify decreasing scalar gradient descent, finite-difference slope, batched linear predictions, MSE, convolution values, attention weighting, and convolution output size.
- The delivery ZIP was separately checked for integrity and equality with the final file tree.

## Length measurement

A named model tokenizer was unavailable locally, and an attempted installation could not obtain one in this environment. The conservative fallback is at least 5,000 whitespace-separated words per final lesson. These are measured whitespace units including code, not asserted model-token counts. The exact tokenizer-specific threshold was not verified.

## Execution limits

PyTorch was unavailable in both checked authoring Python environments. Therefore no PyTorch model training, tensor runtime example, CUDA operation, distributed launch, compiler call, export round trip, pretrained-weight download, server integration, or runtime smoke check was executed here. Syntax validation does not establish API compatibility, convergence, speed, or hardware support.

The supplied `examples/check_runtime.py` checks CPU forward/backward behavior, ignored-token gradients, causal invariance, model shapes, VAE gradient finiteness, artifact parity, and input rejection when run in a compatible environment. It is supplied for later execution and is not listed as passed.

The examples include stochastic training. Printed values and learning curves can vary across releases and devices. Compiler, export, quantization, sharding, and backend support require release-specific verification. External links were used as research references; automated validation checks local navigation, not continuing availability of every website.

## Reproduce the static checks

From the course root:

```bash
python validate_course.py
```

After installing PyTorch:

```bash
python examples/check_runtime.py
```

Use the installation and platform guidance in the README before running advanced examples. No external system was deployed and no scheduled workflow was created.

## Final measurements

| Lesson | Whitespace-separated words |
|---|---:|
| [01-foundations-and-tensors.md](lessons/01-foundations-and-tensors.md) | 5,050 |
| [02-gradients-and-neural-networks.md](lessons/02-gradients-and-neural-networks.md) | 5,034 |
| [03-data-training-and-evaluation.md](lessons/03-data-training-and-evaluation.md) | 5,344 |
| [04-vision-audio-and-transfer-learning.md](lessons/04-vision-audio-and-transfer-learning.md) | 5,005 |
| [05-sequences-attention-and-transformers.md](lessons/05-sequences-attention-and-transformers.md) | 5,262 |
| [06-advanced-autograd-and-ai-objectives.md](lessons/06-advanced-autograd-and-ai-objectives.md) | 5,028 |
| [07-performance-distributed-and-deployment.md](lessons/07-performance-distributed-and-deployment.md) | 5,033 |

Total: **35,756** measured whitespace-separated words across **7 lessons** and **151 numbered sections**.

Static checks passed for **93 lesson code blocks**, **20 Python files**, and **192 relative links**. Seven independent numerical derivation checks passed.
