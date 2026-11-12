# 6. Advanced differentiation and AI objectives

[Previous](05-sequences-attention-and-transformers.md) · [Course index](../README.md) · [Next: scaling and deployment](07-performance-distributed-and-deployment.md)

## Why go beyond a standard supervised loop

Most ordinary models can be written using existing modules and trained with a scalar loss. Advanced work changes one or more assumptions. You may need derivatives with respect to inputs, second derivatives, one gradient per example, a custom mathematical primitive, a latent random variable, or a reward received after a discrete action. These tasks become manageable when you separate the mathematical objective from the derivative estimator and the framework API.

This chapter develops those distinctions through small complete examples. It introduces the central PyTorch mechanisms and several important AI model families. It is an advanced bridge, not a substitute for a complete research course in every generative or reinforcement-learning algorithm. Each example states what it implements and where its scope ends.

## 6.1 A scalar loss hides a vector-Jacobian product

For a vector-valued function `f: R^n -> R^m`, the Jacobian contains every output derivative with respect to every input. Its shape is `[m, n]` for vector inputs and outputs. Storing it can be expensive. Reverse-mode differentiation usually computes a vector-Jacobian product instead: a chosen output sensitivity vector multiplied through the Jacobian.

For a scalar loss, the output sensitivity is one, which makes `loss.backward()` feel automatic. For a nonscalar output, you must specify how outputs are combined or provide an upstream sensitivity. Summing outputs and backpropagating computes the gradient of that sum; it does not return one separate gradient for each output.

```python
import torch

inputs = torch.tensor([2.0, 3.0], requires_grad=True)
outputs = torch.stack([inputs[0] ** 2, inputs[0] * inputs[1]])
upstream = torch.tensor([1.0, 2.0])
(gradient,) = torch.autograd.grad(outputs, inputs, grad_outputs=upstream)
print(gradient)
```

The Jacobian rows are `[4, 0]` and `[3, 2]`. Weighting them by one and two gives `[10, 4]`. `autograd.grad` returns the derivative rather than accumulating into `.grad` under its ordinary use. This is convenient when derivatives are intermediate mathematical objects rather than optimizer inputs stored on parameters.

A Jacobian-vector product propagates an input direction forward instead. It answers how the output changes for a small movement in that direction. Reverse and forward modes have different cost patterns depending on input and output dimensions. Understanding the product needed often avoids constructing a large full Jacobian.

## 6.2 Higher-order derivatives require a differentiable derivative calculation

The derivative of `x³` is `3x²`, and its second derivative is `6x`. If the first derivative is needed as part of another differentiated expression, the framework must record the derivative computation. `create_graph=True` requests that behavior.

```python
import torch

position = torch.tensor(2.0, requires_grad=True)
energy = position ** 3
(first,) = torch.autograd.grad(energy, position, create_graph=True)
(second,) = torch.autograd.grad(first, position)
print(first.item(), second.item())
```

Both values are twelve at position two, though they are different functions. `create_graph` and `retain_graph` solve different problems. The former makes derivatives themselves differentiable. The latter preserves a graph's saved state for reuse. Enabling either unnecessarily can increase memory use, so choose based on the actual derivative computation.

Higher-order derivatives support curvature analysis, gradient penalties, scientific equations, and optimization through optimization. They can be expensive, especially if a full Hessian is constructed. A Hessian-vector product often supplies the required curvature information without storing a square parameter-by-parameter matrix.

## 6.3 Function transforms make derivative structure explicit

The `torch.func` family provides transformations such as `grad`, `jacrev`, `jvp`, and `vmap`. A transformation returns a new function with related behavior. This encourages describing the mathematical computation as a function and asking for a derivative or batched version of it.

```python
import torch
from torch.func import jacrev, jvp

def mapping(inputs):
    return torch.stack([inputs[0] ** 2, inputs[0] * inputs[1]])

point = torch.tensor([2.0, 3.0])
direction = torch.tensor([1.0, -1.0])
jacobian = jacrev(mapping)(point)
value, directional_change = jvp(mapping, (point,), (direction,))
print(jacobian)
print(value, directional_change)
```

The directional change is `[4, 1]`, obtained by multiplying the Jacobian by `[1, -1]`. This example distinguishes a complete derivative matrix from one useful product. For high-dimensional models, choose the smaller object that answers the scientific or engineering question.

Transforms have restrictions. Mutation, data-dependent Python control flow, unsupported operations, and randomness policies can affect compatibility. A function that works in eager mode is not automatically compatible with every transformation. Start with a small pure numerical function, verify its outputs, and consult the transform's contract before scaling up.

## 6.4 Per-example gradients with grad and vmap

An ordinary batch objective averages examples before differentiation. Sometimes you need one gradient for each observation, such as diagnosing influential examples or implementing a specialized clipping algorithm. Vectorizing a single-example gradient function expresses that intent directly.

```python
import torch
from torch.func import grad, vmap

def single_loss(weights, features, target):
    prediction = features @ weights
    return (prediction - target).square()

weights = torch.tensor([0.5, -0.5])
features = torch.tensor([[1.0, 2.0], [3.0, 4.0], [2.0, 0.0]])
targets = torch.tensor([1.0, 2.0, 3.0])
per_example = vmap(grad(single_loss), in_dims=(None, 0, 0))(
    weights, features, targets)
mean_gradient = grad(lambda parameter: vmap(single_loss, in_dims=(None, 0, 0))(
    parameter, features, targets).mean())(weights)
print(per_example.shape)
assert torch.allclose(per_example.mean(0), mean_gradient)
```

`None` means the same weight vector is shared across mapped calls. Zero means map over axis zero of that argument. The resulting shape is `[B, F]`, one parameter-shaped derivative per observation. The equality checks the relationship between averaging individual gradients and differentiating their mean for this independent-example objective.

Batch-dependent operations complicate that interpretation. Batch normalization makes one example's output depend on other examples in training mode. A single-example function then describes a different computation from the original batched model. Be precise about whether “per-example” means independent loss terms in a shared batch computation or separate single-example executions.

## 6.5 Functionalizing a module

A module normally owns parameters and buffers. For transforms or optimization experiments, it can be useful to pass those states explicitly. `functional_call` evaluates a module using supplied state while preserving a familiar forward definition.

```python
import torch
from torch import nn
from torch.func import functional_call, grad

model = nn.Linear(2, 1)
parameters = dict(model.named_parameters())
buffers = dict(model.named_buffers())
features = torch.tensor([[1.0, 2.0], [3.0, 4.0]])
targets = torch.tensor([1.0, 2.0])

def objective(candidate_parameters):
    prediction = functional_call(model, (candidate_parameters, buffers),
                                 (features,)).squeeze(-1)
    return (prediction - targets).square().mean()

derivatives = grad(objective)(parameters)
print({name: tuple(value.shape) for name, value in derivatives.items()})
```

This pattern is useful for meta-learning, ensembles, and derivative transforms. It does not mean all training should be rewritten functionally. Ordinary module-plus-optimizer code is simpler for many tasks. Introduce explicit state when it clarifies a real derivative or batching requirement.

Avoid hidden mutations in a function intended for transformation. Updating running statistics or modifying a captured tensor can make the function's behavior depend on call history. Mathematical notation usually assumes a fixed function, so your implementation should make state changes explicit when they matter.

## 6.6 Custom autograd functions need a mathematical reason

Existing tensor operations already carry derivative rules. If a custom operation can be expressed clearly from them, start there. A custom `autograd.Function` is useful when integrating an external operation or supplying a deliberate derivative rule. It is not required merely because you wrote a new loss formula.

Here is a minimal custom square operation for learning the interface. It intentionally uses the context-style interface and is not presented as automatically compatible with all `torch.func` transforms.

```python
import torch

class Square(torch.autograd.Function):
    @staticmethod
    def forward(ctx, inputs):
        ctx.save_for_backward(inputs)
        return inputs.square()
    @staticmethod
    def backward(ctx, upstream):
        (inputs,) = ctx.saved_tensors
        return upstream * 2 * inputs

inputs = torch.tensor([1.5, -2.0], dtype=torch.float64, requires_grad=True)
outputs = Square.apply(inputs)
outputs.sum().backward()
print(inputs.grad)
check_inputs = torch.randn(3, dtype=torch.float64, requires_grad=True)
assert torch.autograd.gradcheck(Square.apply, (check_inputs,))
```

Backward receives the upstream derivative and returns one derivative per forward input. Multiplying by `2 × inputs` applies the chain rule. `save_for_backward` preserves required tensors under the autograd mechanism rather than storing arbitrary tensor references casually.

`gradcheck` compares analytical and numerical derivatives for a small double-precision example. Avoid nondifferentiable boundaries and overlapping-memory inputs when interpreting failures. A successful check supports the local rule at tested points; it does not prove every shape, dtype, device, or higher-order behavior is correct.

For compatibility with function transforms, the official extension guidance describes a separate `forward` and `setup_context` style plus additional rules. Do not assume the simple class above gains `vmap` or forward-mode support automatically. Interface design is part of correctness when a custom primitive enters a broader ecosystem.

## 6.7 Input gradients and scientific models

A trained model can be differentiated with respect to inputs as well as parameters. This measures local sensitivity of an output to measurements. It is useful for optimization, some attribution methods, and physics-informed objectives. A sensitivity is not automatically a causal effect; changing an input numerically may leave the real-world data manifold.

```python
import torch
from torch import nn

model = nn.Sequential(nn.Linear(2, 8), nn.Tanh(), nn.Linear(8, 1))
model.eval()
features = torch.tensor([[0.2, 0.4]], requires_grad=True)
prediction = model(features).sum()
(sensitivity,) = torch.autograd.grad(prediction, features)
print(sensitivity.shape)
```

Evaluation mode is appropriate, but no-gradient mode would defeat this calculation. This is a concrete example of choosing mode switches independently. If input standardization is inside the model, the derivative is with respect to raw inputs; if you differentiate an already standardized tensor, its units differ.

For a differential equation, a network can represent a smooth function and an objective can penalize the equation's residual using input derivatives. Activation smoothness then matters: a piecewise-linear network has limited classical second-derivative behavior. The physics, boundary conditions, scaling, and sampling design remain essential; autograd alone does not solve the scientific problem.

## 6.8 Probability distributions separate sampling from scoring

`torch.distributions` provides objects with methods such as `sample`, `log_prob`, and, where supported, `rsample`. A distribution's parameters can come from a neural network. `log_prob` evaluates the probability density or mass assigned to an observation; it is not the same as generating an observation.

```python
import torch
from torch.distributions import Normal, Categorical

normal = Normal(loc=torch.tensor(0.0), scale=torch.tensor(1.0))
print(normal.log_prob(torch.tensor(0.0)))
choice = Categorical(logits=torch.tensor([0.0, 1.0, -1.0]))
action = choice.sample()
print(action, choice.log_prob(action))
```

A continuous density can exceed one without violating probability rules because probability is obtained by integrating density over a region. A discrete probability mass is assigned to a specific outcome. Do not interpret a normal distribution's density at a point as the probability of observing exactly that real number.

Distribution objects distinguish sample shape, batch shape, and event shape. Independent normal coordinates can be represented as a batch of scalar events, in which case `log_prob` returns one value per coordinate. Summing over coordinates gives a joint log density under independence. A mistaken mean in place of a sum changes the relative scale of probabilistic objectives.

## 6.9 Reparameterization carries gradients through continuous randomness

Suppose a model predicts mean `mu` and scale `sigma` of a normal latent variable. A direct opaque sample does not expose the usual differentiable path from the sample to those parameters. Reparameterization writes `z = mu + sigma × epsilon`, where epsilon is a standard normal draw independent of the learned parameters.

```python
import torch
from torch.distributions import Normal

mean = torch.tensor(0.5, requires_grad=True)
raw_scale = torch.tensor(-0.2, requires_grad=True)
scale = torch.nn.functional.softplus(raw_scale) + 1e-4
latent = Normal(mean, scale).rsample((32,))
objective = latent.square().mean()
objective.backward()
print(mean.grad, raw_scale.grad)
```

The stochastic sample now has a differentiable path through mean and scale. Softplus ensures a positive scale while allowing an unconstrained parameter. A small positive floor prevents a numerically zero scale. Randomness means one sample estimate varies; averaging multiple draws can reduce variance at additional cost.

This technique applies to distributions with an appropriate reparameterized sampling path. It does not make arbitrary discrete sampling differentiable. Discrete actions require another estimator or a deliberately chosen relaxation, and those have different bias and variance properties.

## 6.10 An autoencoder learns a bottleneck representation

An autoencoder maps an input into a latent representation and reconstructs the input. A narrow latent space can encourage compression of recurring structure. If the model simply copies inputs through a large unrestricted path, low reconstruction error may reveal little useful abstraction.

For real-valued observations, squared reconstruction error corresponds to a fixed-variance Gaussian likelihood up to constants and scale. For binary observations, Bernoulli likelihood is another choice. Match the observation model to the data rather than applying binary cross entropy to arbitrary continuous quantities by habit.

A variational autoencoder makes the latent representation probabilistic and regularizes its approximate posterior toward a prior. The familiar objective combines expected reconstruction negative log-likelihood with a KL divergence term. The encoder predicts distribution parameters; a reparameterized latent sample enters the decoder.

For a diagonal normal approximate posterior and standard normal prior, the KL term per example is

\[
\frac12\sum_j\left(\mu_j^2+e^{\log\sigma_j^2}-1-\log\sigma_j^2\right).
\]

This expression is zero when every mean is zero and every variance is one. It penalizes deviations from the prior, while reconstruction encourages latents to retain information about observations. The competing terms define a tradeoff, not a guarantee of interpretable latent coordinates.

## 6.11 A complete two-dimensional variational autoencoder

The following program fits a tiny VAE to a two-dimensional mixture. It uses a Gaussian-style squared reconstruction term and an explicit latent KL term. It demonstrates the mechanism without requiring image files.

```python
import torch
from torch import nn

class TinyVAE(nn.Module):
    def __init__(self):
        super().__init__()
        self.encoder = nn.Sequential(nn.Linear(2, 16), nn.Tanh())
        self.mean = nn.Linear(16, 2)
        self.log_variance = nn.Linear(16, 2)
        self.decoder = nn.Sequential(nn.Linear(2, 16), nn.Tanh(), nn.Linear(16, 2))
    def forward(self, observations):
        hidden = self.encoder(observations)
        mean = self.mean(hidden)
        log_variance = self.log_variance(hidden).clamp(-8, 8)
        latent = mean + torch.exp(0.5 * log_variance) * torch.randn_like(mean)
        return self.decoder(latent), mean, log_variance

def main():
    torch.manual_seed(61)
    cluster = torch.randint(0, 2, (512, 1)).float()
    observations = torch.cat([2 * cluster - 1, 1 - 2 * cluster], dim=1)
    observations += 0.2 * torch.randn_like(observations)
    model = TinyVAE()
    optimizer = torch.optim.Adam(model.parameters(), lr=0.01)
    for step in range(300):
        indices = torch.randint(0, len(observations), (64,))
        batch = observations[indices]
        reconstruction, mean, log_variance = model(batch)
        reconstruction_term = 0.5 * (reconstruction - batch).square().sum(-1)
        kl = 0.5 * (mean.square() + log_variance.exp() - 1 - log_variance).sum(-1)
        loss = (reconstruction_term + kl).mean()
        optimizer.zero_grad(set_to_none=True)
        loss.backward()
        optimizer.step()
        if step % 100 == 0:
            print(step, loss.item(), reconstruction_term.mean().item(), kl.mean().item())
    model.eval()
    with torch.no_grad():
        generated = model.decoder(torch.randn(5, 2))
    print(generated)

if __name__ == '__main__':
    main()
```

The reconstruction term sums coordinate errors before averaging examples, matching the KL's latent-coordinate sum. Changing one term to an all-element mean would change their relative weight. The log-variance clamp is a simple numerical guard for this teaching example and also restricts the parameterization; it is not a universal VAE recipe.

A tiny VAE can exhibit posterior collapse or generate overly smooth samples. The program is a mechanism demonstration, not a promise of perfect mixture recovery. Inspect reconstruction and KL separately so a falling total loss does not hide a latent representation that carries almost no information.

## 6.12 Denoising connects to diffusion training

A denoiser learns to recover structure from a corrupted observation. In a diffusion-style objective, clean data `x0` is combined with Gaussian noise at a sampled noise level:

\[
x_t=\sqrt{\bar\alpha_t}x_0+\sqrt{1-\bar\alpha_t}\epsilon.
\]

A network receives the noisy observation and a representation of time or noise level, then predicts the added noise. Squared error between predicted and actual noise supplies a supervised learning signal. The network architecture can be a CNN, transformer, or another suitable function.

```python
import torch
from torch import nn

torch.manual_seed(67)
model = nn.Sequential(nn.Linear(3, 32), nn.SiLU(), nn.Linear(32, 2))
optimizer = torch.optim.Adam(model.parameters(), lr=1e-3)
clean = torch.randn(64, 2)
noise_level = torch.rand(64, 1)
alpha_bar = (1.0 - 0.95 * noise_level).clamp(0.01, 0.99)
noise = torch.randn_like(clean)
noisy = alpha_bar.sqrt() * clean + (1 - alpha_bar).sqrt() * noise
prediction = model(torch.cat([noisy, noise_level], dim=1))
loss = (prediction - noise).square().mean()
optimizer.zero_grad(set_to_none=True)
loss.backward()
optimizer.step()
print(loss.item())
```

This is a complete noise-prediction training step with a simple continuous noise-level parameterization. It is not a complete DDPM sampler, and the chosen level schedule is educational rather than a reproduction of a paper. Generation requires a consistent reverse process, schedule, and sampling rule. Learning to predict noise is only one part of that system.

The conceptual connection is valuable: a complicated generative model can still use ordinary tensors, a conditioned neural network, an explicit target, and backpropagation. Understanding those components lets you read specialized diffusion implementations without mistaking their objective for unexplained magic.

## 6.13 Reinforcement learning changes where the target comes from

In supervised learning, an observed target is provided. In reinforcement learning, an agent selects actions and receives rewards through interaction. Actions can affect future observations, and feedback may be delayed. The objective concerns expected return, often a discounted sum of future rewards.

A simple bandit removes state transitions and delay. The agent chooses one of several actions, receives a reward, and tries to increase expected reward. This isolates the problem of learning through a discrete sample. Ordinary differentiation cannot pass through the sampled integer action as though it were continuous.

The score-function identity provides another route:

\[
\nabla_\theta\mathbb{E}_{a\sim\pi_\theta}[R(a)]
=\mathbb{E}[R(a)\nabla_\theta\log\pi_\theta(a)].
\]

A sampled reward multiplied by a log-probability gradient estimates the expected-return gradient. To minimize a loss while maximizing return, use the negative of that quantity. A reward baseline independent of the sampled action can reduce variance without changing the expectation under the relevant assumptions.

```python
import torch
from torch import nn
from torch.distributions import Categorical

torch.manual_seed(71)
logits = nn.Parameter(torch.zeros(3))
optimizer = torch.optim.Adam([logits], lr=0.05)
reward_means = torch.tensor([0.0, 0.5, 1.0])
baseline = 0.0
for step in range(400):
    policy = Categorical(logits=logits)
    action = policy.sample()
    reward = reward_means[action] + 0.2 * torch.randn(())
    advantage = reward - baseline
    loss = -policy.log_prob(action) * advantage.detach()
    optimizer.zero_grad(set_to_none=True)
    loss.backward()
    optimizer.step()
    baseline = 0.95 * baseline + 0.05 * reward.item()
print(logits.softmax(-1).detach())
```

The policy should tend to favor the third action, but stochastic learning is not an exact-output guarantee. The baseline is updated after forming the advantage from its previous value. The example has no future state, discounting, replay buffer, or value network, so it is a policy-gradient bandit rather than a full control algorithm.

## 6.14 Value learning and target detachment

A value-based method estimates expected future return. In Q-learning, a target often combines immediate reward with a discounted estimate of the best next-action value. A target network and replay buffer can stabilize learning by reducing rapid target changes and reusing experience.

The target is ordinarily treated as fixed for the current prediction update. If gradients unintentionally flow through the bootstrap target, the implemented optimization differs from the intended semi-gradient method. This is a principled use of `no_grad` or detachment, contrasting with accidental graph breaks in supervised losses.

Termination and time-limit truncation are different environment events. A true terminal state may have no future return, while an artificial time limit can require bootstrapping depending on the task formulation. Collapsing both into one Boolean without understanding the environment can introduce biased targets. Consult the environment contract and algorithm definition together.

The official DQN tutorial is a useful next implementation because it adds the control loop, replay, target network, and environment bookkeeping. The bandit here establishes the discrete-gradient issue first, so those additional components have a clear purpose.

## 6.15 Responsible boundaries for advanced objectives

A loss can be differentiable and still fail to represent the intended task. A custom derivative can pass a local check and still break a transformation. A generative model can produce plausible samples while missing important modes. An agent can maximize a proxy reward while behaving undesirably. These are distinct problems requiring different evidence.

Keep a reference implementation small enough to inspect. Validate shapes and reductions before optimizing. Compare gradients numerically for custom rules. Inspect generated distributions rather than only one attractive sample. Evaluate a policy across independent runs rather than one lucky trajectory. The consistent habit is connecting a mathematical claim to an observable test.

## 6.16 Deriving the variational objective carefully

A latent-variable model defines a joint density `p(x, z) = p(x | z) p(z)`. The observed-data likelihood requires integrating out the latent variable: `p(x) = integral p(x, z) dz`. That integral is difficult for many neural decoders. Introduce an approximate posterior `q(z | x)` and rewrite the integral as an expectation under it.

Applying the concavity of the logarithm gives a lower bound on `log p(x)`: the expectation under `q` of `log p(x, z) - log q(z | x)`. Expanding the joint separates this into expected reconstruction log-likelihood minus `KL(q(z | x) || p(z))`. Maximizing this lower bound is equivalent to minimizing the reconstruction negative log-likelihood plus KL used in the example.

The gap between the true log likelihood and this bound equals `KL(q(z | x) || p(z | x))` under suitable conditions. Because KL is nonnegative, the expression is a lower bound. This gives the encoder a precise role: it approximates the model's posterior, rather than merely compressing inputs into arbitrary noisy codes.

The reparameterization step supplies a practical derivative estimator for the expectation when the posterior is a suitable continuous distribution. It does not make the bound exact. Approximation error, limited decoder capacity, finite data, and stochastic optimization all remain. This distinction helps interpret why a VAE can optimize its stated objective without producing the sample quality you hoped for.

For continuous observations, the reconstruction scale corresponds to a likelihood variance assumption. Multiplying squared error by a different constant changes its balance with KL. If you introduce a beta coefficient on KL, you are deliberately changing the objective's tradeoff. Name that modification rather than describing every reconstruction-plus-regularizer formula as the same probabilistic model.

## 6.17 Batch shape and event shape in a practical example

Suppose a network predicts a two-dimensional independent normal distribution for each of four examples. Mean and scale tensors have shape `[4, 2]`. Constructing `Normal(mean, scale)` treats both axes as batch dimensions of scalar distributions. `log_prob(observations)` then returns `[4, 2]`, one scalar-coordinate log density per example and coordinate.

Wrapping that object in `Independent(..., 1)` reinterprets the final batch axis as an event axis. The resulting distribution has batch shape `[4]` and event shape `[2]`. Its log probability returns one joint log density per example, summing the two independent coordinates.

```python
import torch
from torch.distributions import Normal, Independent

mean = torch.zeros(4, 2)
scale = torch.ones(4, 2)
observations = torch.randn(4, 2)
coordinate_distribution = Normal(mean, scale)
vector_distribution = Independent(coordinate_distribution, 1)
coordinate_scores = coordinate_distribution.log_prob(observations)
vector_scores = vector_distribution.log_prob(observations)
print(coordinate_scores.shape, vector_scores.shape)
assert torch.allclose(coordinate_scores.sum(-1), vector_scores)
```

This is a semantic distinction, not just an output convenience. It determines which dimensions represent independent dataset cases and which dimensions jointly describe one outcome. Sampling can add still more leading dimensions. Write those roles explicitly before reducing a probabilistic objective, especially in hierarchical models where an accidental sum or mean can silently alter the intended likelihood.

## 6.18 Contrastive learning builds representations through comparisons

A supervised classifier receives a target class. A contrastive objective instead defines which representations should be similar and which should be distinguishable. For example, two permitted augmentations of the same observation can form a positive pair. Other observations in a batch can provide negative comparisons under a particular method.

Normalize representation vectors to separate direction from magnitude, compute pairwise dot-product similarities, divide by a positive temperature, and use a classification-style objective to identify the matching partner. The temperature controls how concentrated the comparison distribution is and changes gradient behavior.

```python
import torch
from torch.nn import functional as F

first = F.normalize(torch.randn(4, 8, requires_grad=True), dim=-1)
second = F.normalize(torch.randn(4, 8, requires_grad=True), dim=-1)
scores = first @ second.T / 0.2
matching_indices = torch.arange(4)
loss = 0.5 * (F.cross_entropy(scores, matching_indices)
              + F.cross_entropy(scores.T, matching_indices))
loss.backward()
print(loss.item())
```

This complete calculation demonstrates a symmetric paired objective on synthetic representations. It does not define an image augmentation policy, encoder, or full training experiment. The diagonal correspondence supplies supervision: row `i` should match column `i`. A real application must justify why those pairs share the intended information.

False negatives arise when two different observations should actually be similar but the objective treats them as competitors. A representation can also learn augmentation artifacts rather than semantic structure. Evaluate on downstream tasks and controlled retrieval cases instead of assuming that a lower contrastive loss guarantees a universally useful embedding.

## 6.19 Adversarial training introduces two coupled objectives

A generative adversarial model trains a generator to produce samples and a discriminator to distinguish generated from observed samples. The two networks receive different objectives and are updated in alternating phases. This differs from minimizing one fixed supervised loss because each network changes the other's learning problem.

During a discriminator update, generated samples are commonly detached so the generator does not receive that phase's gradients. During a generator update, the generated sample must remain connected to the generator, while discriminator parameters need not accumulate updates. The discriminator computation still supplies derivatives with respect to its input, so wrapping its entire forward pass in `no_grad` would remove the generator's learning signal.

This is an excellent example of why “freeze a model” is ambiguous. Setting discriminator parameters to not require gradients can preserve input derivatives. Disabling all gradient recording through the discriminator cannot. Training mode and running-statistic behavior add another independent consideration.

Adversarial methods can suffer from unstable dynamics and mode collapse, where generated samples cover only part of the target distribution. A low loss or a few impressive outputs is insufficient evaluation. This chapter introduces the gradient-boundary reasoning needed to read such training loops; a full GAN implementation should specify its exact objectives and evaluation protocol rather than being inferred from these conceptual notes.

## 6.20 Differentiable linear algebra and stable problem formulation

Neural computation sometimes includes solving a linear system, estimating a projection, or decomposing a matrix. PyTorch supplies linear algebra operations, many with autograd support under stated conditions. Prefer solving a system directly to explicitly computing a matrix inverse when your mathematical goal is `A x = b`.

```python
import torch

matrix = torch.tensor([[3.0, 1.0], [1.0, 2.0]],
                       dtype=torch.float64, requires_grad=True)
right_hand_side = torch.tensor([1.0, 0.0], dtype=torch.float64)
solution = torch.linalg.solve(matrix, right_hand_side)
objective = solution.square().sum()
objective.backward()
print(solution)
print(matrix.grad)
```

The system is nonsingular, so the solution exists uniquely. If the matrix becomes nearly singular, small input perturbations can create large solution changes and large derivatives. That is mathematical conditioning, not necessarily an autograd bug. Regularization or a different parameterization may be needed, but should be justified by the task.

Eigenvectors and singular vectors can also become ambiguous when associated values repeat. Derivatives of quantities depending on a particular basis may be unstable near such degeneracies. Consult the operation-specific documentation and test the numerical regime your model actually reaches. The presence of a backward implementation is not a promise that every mathematical formulation is well-conditioned.

## 6.21 Einsum makes contractions readable when indices have meaning

Einstein summation notation names axes with letters and states which remain in the output. For example, `bf,fo->bo` expresses batched feature projection, exactly the matrix multiplication used earlier. Repeated labels omitted from the output are summed. The notation is useful when a contraction has several batch or head axes and ordinary matmul reshaping becomes hard to read.

```python
import torch

features = torch.randn(3, 4)
weights = torch.randn(4, 2)
projected = torch.einsum('bf,fo->bo', features, weights)
assert torch.allclose(projected, features @ weights)
queries = torch.randn(2, 3, 5, 4)
keys = torch.randn(2, 3, 7, 4)
scores = torch.einsum('bhtd,bhsd->bhts', queries, keys)
print(scores.shape)
```

The attention score shape is `[2, 3, 5, 7]`: batch, heads, query positions, source positions. Distinct letters for query and source length make rectangular attention explicit. The feature letter disappears because it is contracted. This is the same shape reasoning from Chapter 1 expressed more compactly.

Do not use terse notation to hide an unclear calculation. Define each letter in prose or a nearby comment. A readable contraction is valuable because it exposes the mathematical intent; an unexplained string can be as opaque as a chain of arbitrary reshapes.

## 6.22 Sparse structure and indexing gradients

An embedding table may contain millions of rows while one batch references only a small subset. This motivates sparse representations and sparse gradient updates. Sparse storage describes nonzero entries without allocating every possible zero. Its benefit depends on the pattern, density, and supported operations; a mostly zero dense tensor does not automatically execute as a sparse operation.

Some embedding configurations can produce sparse gradients, but optimizer compatibility is restricted. Do not switch `sparse=True` and assume an existing adaptive optimizer supports the resulting gradient format. Consult the embedding and optimizer contracts together. The mathematical objective can remain unchanged while the storage and update implementation require a different pairing.

Indexing and gathering propagate gradients to selected floating-point source entries. Repeated indices can accumulate multiple contributions. The indices themselves remain discrete. Scatter operations express the reverse organization: place or accumulate values into indexed destinations. When several contributions target the same location, distinguish replacement from addition and consider determinism on the relevant device.

These tools are common in graph networks, recommendation systems, and variable-length batching. The first-principles method remains useful: name the entity represented by each axis, identify the source-to-destination mapping, and define how repeated contributions combine. A complicated indexing expression becomes understandable once its scalar meaning is written down.

## 6.23 Choosing the right derivative estimator

There are now three different situations in view. Ordinary deterministic differentiable operations use the chain rule directly. Reparameterized continuous samples express randomness through an independent base draw and preserve a pathwise derivative. Discrete sampled actions can use a score-function estimator based on log probability. These are not interchangeable ways to call backward.

A pathwise estimator often has useful variance properties when available, but it requires a suitable transformation. A score-function estimator applies more broadly but can have high variance, motivating baselines and additional structure. A continuous relaxation changes the computation to obtain a differentiable surrogate, introducing a relationship between the surrogate objective and the original discrete problem that must be evaluated.

When an advanced model fails, identify which estimator it is actually using before debugging optimizer settings. A detached sample with no alternative estimator has no learning path. An estimator with the wrong sign can optimize against the intended goal. A numerically correct estimate of an unsuitable reward can learn an unsuitable behavior. State the objective, estimator, and update rule separately, then verify each on a tiny problem with an understandable solution.

This separation is the practical payoff of the chapter. You can now recognize when a new AI method is introducing a representation, a probability model, a gradient estimator, or an execution optimization. Each deserves a different explanation and a different kind of evidence.

A final useful discipline is to preserve the simplest verified version before adding another estimator or transformation. That reference gives numerical comparisons a stable meaning and prevents several simultaneous changes from obscuring the source of a failure.

## Sources

Consult [torch.func.jacrev](https://docs.pytorch.org/docs/2.15/generated/torch.func.jacrev.html), [function-transform extension guidance](https://docs.pytorch.org/docs/stable/notes/extending.func.html), [distributions](https://docs.pytorch.org/docs/2.15/distributions.html), and the official [DQN tutorial](https://docs.pytorch.org/tutorials/intermediate/reinforcement_q_learning.html). Research context: Kingma and Welling, [Auto-Encoding Variational Bayes](https://arxiv.org/abs/1312.6114); Ho, Jain, and Abbeel, [Denoising Diffusion Probabilistic Models](https://arxiv.org/abs/2006.11239). These links identify the originating methods; the small examples are original and are not full paper reproductions. Accessed November 12, 2026.
