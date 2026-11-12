# Validation report

Created November 12, 2026.

## Completed checks

- Five numbered lesson files exist, with course navigation and source links.
- All lessons exceed the conservative **5,000 whitespace-separated words** proxy. Counts use Python `len(text.split())`, including code, equations, tables, and prose.
- Python syntax parsing passes for **71 inline Python blocks** and **seven Python files**: five standalone learning examples and two verification tools.
- Markdown code fences are balanced and relative file links resolve. Link validation excludes code blocks so Python indexing syntax is not mistaken for a Markdown link. External link availability is not exhaustively tested.
- Independent NumPy calculations pass for the forward-pass examples, broadcasting shapes, scalar finite-difference gradient, dense-layer finite-difference gradients, stable binary cross-entropy, unequal-batch weighting, convolution arithmetic, and attention normalization.
- Source coverage was mapped to the supplied primer, with historical APIs distinguished from the TensorFlow 2 baseline.
- The final archive was checked for integrity, expected paths, and exact byte parity with packaged source files.

| Lesson | Whitespace words |
| --- | ---: |
| 1 — Tensors and mathematical foundations | 5,052 |
| 2 — Derivatives, losses, and optimization | 5,048 |
| 3 — Keras, data, and experiments | 5,115 |
| 4 — Architectures and generative objectives | 5,012 |
| 5 — Advanced execution and delivery | 5,184 |
| **Total lesson words** | **25,411** |

## Important verification limits

**TensorFlow is not installed in the authoring environment. No TensorFlow model training, graph execution, checkpoint restoration, SavedModel export, edge conversion, mixed precision, GPU execution, or distributed execution was run here.** Syntax checking is not runtime validation. The independent math checks validate selected calculations without validating TensorFlow API integration.

A suitable model tokenizer was unavailable. The configured package source did not provide `tiktoken` when installation was attempted. Exact model-token counts are therefore **not verified**; word counts are explicitly a conservative measurable proxy rather than a token measurement.

The package selects Python 3.11 and TensorFlow 2.20.0 as a reference, while transitive dependencies including Keras resolve at installation. It is not a complete platform-specific environment lock and does not claim latest-version status. Record your successful resolved environment before changing dependencies.

Pretrained-weight downloads are not required by the standalone scripts. The transfer-learning construction in Chapter 4 uses random weights and explicitly labels itself as a mechanics demonstration. No real-world accuracy or performance benchmark is claimed.

## Reproduce the checks

From the unzipped course folder:

```bash
python tools/validate_curriculum.py
python tools/verify_math.py
```

For runtime validation in an installed TensorFlow environment:

```bash
python examples/math_lab.py
python examples/pipeline_demo.py
python examples/tabular_capstone.py
python examples/attention_demo.py
python examples/custom_loop.py
python examples/tabular_capstone.py --output artifacts/export_check --export
```

These are verification commands for the reader to run, not a record that they were executed successfully during authoring. The examples include assertions for mathematical values, causal prefix behavior, training improvement, and model reload parity where appropriate. Device-specific and edge-runtime checks require the corresponding hardware/runtime and representative inputs.
