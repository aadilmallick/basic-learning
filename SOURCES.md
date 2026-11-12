# Source register and scope

Research date: November 12, 2026. Lessons and examples are original instructional material. Links identify source contracts and further reading; they do not imply that the original authors tested these teaching programs.

## Starting reference and coverage

[Aman PyTorch primer](https://aman.ai/primers/pytorch/) was inspected in its tensor/sequence and model-lifecycle sections. Its broad coverage was reorganized rather than copied.

| Source theme | Curriculum location |
|---|---|
| Tensor operations, shapes, initialization, devices | Lessons 1–2; einsum in Lesson 6 |
| Padded text, embeddings, recurrent tagging | Lesson 5 |
| Data preparation, loaders, vision/text/audio | Lessons 3–5 |
| Model training, fine-tuning, checkpointing | Lessons 2–5 |
| Hyperparameter experimentation | Lesson 3 |
| Deployment, monitoring, workflow orchestration | Lesson 7 |

Additional material develops the mathematical prerequisites, transformer construction, advanced differentiation, probabilistic objectives, and scaling decisions. Older source patterns are updated through official API contracts. The source's external-tool workflows motivate lifecycle design; this course does not claim full Airflow, Prefect, or third-party experiment-platform instruction.

## Official PyTorch references

| Reference | Main use | Version or uncertainty |
|---|---|---|
| [Installation selector](https://pytorch.org/get-started/locally/) | Platform-specific installation | Live selector; select the actual machine |
| [Learn the basics](https://docs.pytorch.org/tutorials/beginner/basics/intro.html) | Core workflow and tutorial navigation | Page exposed 2.15 tutorial documentation |
| [Autograd mechanics](https://docs.pytorch.org/docs/2.15/notes/autograd.html) | Graph and gradient behavior | 2.15 |
| [CrossEntropyLoss](https://docs.pytorch.org/docs/2.15/generated/torch.nn.CrossEntropyLoss.html) | Logits and class-target contract | 2.15 |
| [Data utilities](https://docs.pytorch.org/docs/2.15/data.html) | Dataset, loader, and sampling contracts | 2.15 |
| [Reproducibility](https://docs.pytorch.org/docs/2.15/notes/randomness.html) | Limits of deterministic reproduction | 2.15 |
| [Serialization](https://docs.pytorch.org/docs/2.15/notes/serialization.html) | State and restricted loading | 2.15 |
| [Conv2d](https://docs.pytorch.org/docs/2.15/generated/torch.nn.Conv2d.html) | Convolution layout and geometry | 2.15 |
| [ResNet-18](https://docs.pytorch.org/vision/stable/models/generated/torchvision.models.resnet18.html) | Weights enum and preprocessing | Stable page exposed torchvision 0.29 |
| [LSTM](https://docs.pytorch.org/docs/2.15/generated/torch.nn.LSTM.html) | Sequence and hidden-state contracts | 2.15 |
| [Scaled dot-product attention](https://docs.pytorch.org/docs/2.15/generated/torch.nn.functional.scaled_dot_product_attention.html) | Mask permission and dropout | 2.15; check backend constraints |
| [MultiheadAttention](https://docs.pytorch.org/docs/stable/generated/torch.nn.MultiheadAttention) | Opposite padding-mask convention | Stable alias; cached results also exposed 2.14 |
| [torch.func.grad](https://docs.pytorch.org/docs/stable/generated/torch.func.grad.html) | Derivative transforms | Stable alias; searched result exposed 2.14 |
| [torch.func.jacrev](https://docs.pytorch.org/docs/2.15/generated/torch.func.jacrev.html) | Full Jacobian transform | 2.15 |
| [Extending function transforms](https://docs.pytorch.org/docs/2.15/notes/extending.func.html) | Custom autograd compatibility | 2.15 |
| [gradcheck](https://docs.pytorch.org/docs/stable/generated/torch.autograd.gradcheck.html) | Numerical derivative checks | Search result inspected; direct 2.15 page fetch failed |
| [Distributions](https://docs.pytorch.org/docs/2.15/distributions.html) | Sampling, log probabilities, shapes | 2.15 |
| [DQN tutorial](https://docs.pytorch.org/tutorials/intermediate/reinforcement_q_learning.html) | Full RL continuation | 2.15 tutorial documentation |
| [AMP](https://docs.pytorch.org/docs/2.15/amp.html) | Autocast/scaling and compiler interaction | 2.15; compose with compile only after checking release semantics |
| [compile](https://docs.pytorch.org/docs/2.15/generated/torch.compile.html) | Compilation contract | 2.15; backend/platform dependent |
| [Profiler](https://docs.pytorch.org/tutorials/recipes/recipes/profiler_recipe.html) | Operator measurement | 2.15 tutorial documentation |
| [DDP](https://docs.pytorch.org/docs/2.15/generated/torch.nn.parallel.DistributedDataParallel.html) | Replication and synchronization | 2.15 |
| [FSDP2 tutorial](https://docs.pytorch.org/tutorials/intermediate/FSDP_tutorial.html) | Sharded-training continuation | 2.15 tutorial documentation; hardware-specific execution untested |
| [Export overview](https://docs.pytorch.org/docs/main/user_guide/torch_compiler/export.html) | Export versus compile | Development documentation; stable short-path fetch failed |
| [ONNX](https://docs.pytorch.org/docs/2.15/onnx.html) | Interchange contract | 2.15; target runtime untested |
| [torchao](https://docs.pytorch.org/ao/stable/index.html) | Quantization routes | Page exposed torchao 0.17 |

The documentation versions above describe retrieved pages, not an installed runtime used to execute the examples. Stable aliases and search caches disagreed in places. Version-sensitive sections explicitly avoid universal compatibility claims, and installation should follow the official selector rather than a guessed global pin.

## Research origins and other primary sources

- Kingma and Welling, [Auto-Encoding Variational Bayes](https://arxiv.org/abs/1312.6114). Origin and high-level context for variational autoencoders. The course's derivation and two-dimensional program are original, not a paper reproduction.
- Ho, Jain, and Abbeel, [Denoising Diffusion Probabilistic Models](https://arxiv.org/abs/2006.11239). Origin and context for diffusion noise prediction. The lesson implements a training-step illustration, not the complete published sampler.
- Hu and colleagues, [LoRA](https://arxiv.org/abs/2106.09685). Origin and context for low-rank adaptation. The small adapter is an educational projection wrapper, not a drop-in implementation for every pretrained architecture.
- Python, [http.server](https://docs.python.org/3/library/http.server.html). Contract for the local-only demonstration server. The module is not recommended as a production hosting stack.

Paper landing pages and abstracts were consulted for method provenance. The course does not claim exhaustive paper review or benchmark reproduction. All sources were accessed on the research date above. No external credentials, pretrained services, paid tools, or third-party workflow engines are assumed available.
