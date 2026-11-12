# PyTorch from first principles

A complete core curriculum in seven substantial Markdown lessons, from tensors and the mathematics of learning to neural architectures, advanced differentiation, scaling, and deployment.

Prepared for Aadil Mallick · November 12, 2026

## Start here

Begin with [Lesson 1: foundations and tensors](lessons/01-foundations-and-tensors.md). Read the numbered sections slowly; each is a manageable study session within a longer chapter. Continue in order unless you already understand a prerequisite. This is a finished set of teaching chapters, not an outline awaiting future content.

The course assumes basic programming experience and teaches the Python features and mathematics it uses. It does not assume previous neural-network training experience. A CPU is sufficient for foundational examples and the supplied self-contained modeling demonstrations. The AMP example explicitly requires CUDA. Compiler, export, distributed, and pretrained-weight examples have additional stated environment requirements.

## Learning path

| Lesson | Prerequisites | What you will understand and build |
|---|---|---|
| [1. Foundations and tensors](lessons/01-foundations-and-tensors.md) | Basic programming | Python essentials; scalar/vector/matrix meaning; tensor attributes; dot products and matrix multiplication; reductions; broadcasting; indexing; views and copies; device movement; training-only standardization; a transparent regression calculation. |
| [2. Gradients and neural networks](lessons/02-gradients-and-neural-networks.md) | Lesson 1 | Derivatives; finite differences; gradient descent; chain rule and backpropagation; autograd lifetime and accumulation; modules and registration; activations; regression and classification objectives; stable logits; SGD/Adam; initialization; a complete nonlinear classifier; analytic gradient checks. |
| [3. Data, training, and evaluation](lessons/03-data-training-and-evaluation.md) | Lessons 1–2 | Dataset and loader contracts; leakage-resistant splitting; fitted transformations and buffers; training/validation loops; correctly weighted metrics; calibration; regularization; reproducibility; checkpoints; missing-label masks; class imbalance; hyperparameter trials; a full regression experiment. |
| [4. Vision, audio, and transfer](lessons/04-vision-audio-and-transfer-learning.md) | Lessons 1–3 | Convolution arithmetic and geometry; receptive fields; pooling; CNN training; normalization; residual connections; transfer and fine-tuning; augmentation; segmentation/detection contracts; waveforms and spectrograms; depthwise convolution; a complete generated-image classifier. |
| [5. Sequences, attention, and transformers](lessons/05-sequences-attention-and-transformers.md) | Lessons 1–4 | Tokenization and vocabulary identity; padding and masks; embeddings; sequence baselines; LSTMs and packing; token tagging; attention mathematics; multihead attention; causal masking; position representations; a complete tiny transformer; generation; perplexity; low-rank adaptation. |
| [6. Advanced autograd and AI objectives](lessons/06-advanced-autograd-and-ai-objectives.md) | Lessons 1–5 | VJPs/JVPs; higher derivatives; torch.func; functional modules; per-example gradients; custom autograd and gradcheck; input sensitivity; distribution shapes; reparameterization; VAE derivation and implementation; diffusion-style noise prediction; policy-gradient bandits; value-learning boundaries; contrastive objectives; adversarial gradient flow; linear algebra and einsum. |
| [7. Performance, distributed training, and deployment](lessons/07-performance-distributed-and-deployment.md) | Lessons 1–6 | Measurement and profiling; memory budgets; AMP; accumulation; compile; complete CPU DDP; global metric aggregation; sharding and parallelism decisions; export; ONNX and quantization tradeoffs; saved-artifact inference; a complete capstone; a local HTTP adapter; orchestration, monitoring, and promotion. |

## Study format

Each lesson is a long textbook-style chapter with smaller sections. There are 151 numbered instructional sections across the seven lessons. Treat a section or a few closely related sections as one sitting, rather than rushing through an entire file. Read the explanation, run its small example when your environment is ready, and inspect the shapes and values before moving on.

The learning sequence is problem → intuition → mathematical definition → small implementation → explanation → realistic use → limitations and debugging. Optional applications are offered without mandatory quizzes or recall gates. You can return to this chat with a section number for a slower guided walkthrough.

Mathematics is introduced as needed: weighted sums, dimensions, means and variance, derivatives, the chain rule, probability and log likelihood, vector products, latent-variable bounds, and gradient estimators. Code examples isolate the meaning of those formulas rather than replacing the explanation with an unexplained training wrapper.

## Environment

Create a virtual environment using the commands in Lesson 1, then use the official [PyTorch installation selector](https://pytorch.org/get-started/locally/) for your operating system, Python version, and compute platform. The course uses established PyTorch 2.x interfaces. Consulted documentation primarily resolved to 2.15; some search results were cached at 2.14. No untested claim of exact compatibility across all 2.x releases is made.

Most examples need only Python and `torch`. The pretrained ResNet example also needs a compatible `torchvision` and access to its weights. Audio demonstrations use generated waveforms and core PyTorch operations. Text demonstrations use self-contained vocabularies, avoiding a required external corpus or tokenizer service. The local HTTP adapter uses Python's standard library.

## Supplied scripts

The [examples directory](examples/README.md) contains selected complete programs extracted from the lessons, including regression, image classification, a tiny transformer, a VAE, a policy-gradient bandit, CPU DDP, and the capstone. The Markdown chapters remain the teaching source; the scripts make running the larger examples easier.

```bash
python examples/01_scalar_gradient_descent.py
python examples/03_regression_experiment.py
python examples/04_cnn_bars.py
python examples/05_tiny_transformer.py
python examples/06_tiny_vae.py
python examples/capstone.py
```

Run programs from a directory where you want their output artifacts written. Pretrained downloads, long training demonstrations, compiler initialization, and server processes are never launched automatically by opening this course.

For distributed execution, use the separate launch command documented in Lesson 7 and the examples index. For the local server, run the capstone first and keep both files in the same examples directory; the examples index gives the exact working-directory sequence.

## Relationship to the supplied primer

The starting reference is the [Aman PyTorch primer](https://aman.ai/primers/pytorch/). Its tensor, sequence, training, experimentation, and model-lifecycle themes inform the coverage. This curriculum reorganizes those themes into prerequisite order and adds original derivations, self-contained programs, and explicit failure analysis. It does not reproduce the source text.

Historical patterns such as `Variable`, `.data`-based mutation, and fragile manual padding-loss indexing are replaced with direct tensors, explicit gradient contexts, and validated masking contracts. Source examples depending on undeclared external model classes are replaced by complete teaching implementations or clearly labeled continuation fragments.

“Complete” here means the entire planned foundations-to-advanced core course is written. It does not mean every PyTorch API, every backend integration, or every AI research field is exhaustively covered. Specialized areas such as full object-detection systems, cluster-specific FSDP configuration, complete diffusion samplers, and large-scale RL receive a conceptual bridge and documented continuation rather than a false claim of complete standalone specialization.

## Verification and limitations

See [VALIDATION.md](VALIDATION.md) for measured lengths and checks. Every lesson meets a conservative proxy of at least 5,000 whitespace-separated words. An appropriate model tokenizer could not be obtained in the authoring environment, so exact model-token counts are not asserted.

All Python snippets and supplied scripts were syntax-checked. The small pure-Python calculus examples were executed and independent hand-calculation properties were checked. PyTorch was unavailable in the authoring environment, so training, CUDA, distributed, compiler, export, pretrained downloads, and server integration were not executed there. The runtime smoke-check script is supplied for a machine with PyTorch installed.

Read the [source register](SOURCES.md) for official references, dates, version qualifications, and coverage mapping. The [detailed section index](LESSON-INDEX.md) links directly to every numbered section.
