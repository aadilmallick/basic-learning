# 5. From token sequences to transformers

[Previous](04-vision-audio-and-transfer-learning.md) · [Course index](../README.md) · [Next: advanced modeling](06-advanced-autograd-and-ai-objectives.md)

## Why sequence structure matters

A sentence is not merely a bag of measurements. Word order changes meaning, sentence lengths differ, and the relevant context for one word may be far away. Similar issues arise in event streams, biological sequences, and time series. This chapter develops the representations and operations needed to model such inputs in PyTorch.

We will begin with token identifiers and padding, build an embedding and recurrent model, derive attention as a weighted information lookup, and implement a small causal transformer. Mathematical notation is paired with explicit shapes throughout. The goal is to understand a model's information flow and objective, including which tokens it is allowed to see and which positions contribute to learning.

## 5.1 Tokenization establishes a vocabulary contract

A tokenizer converts raw text into a sequence of discrete units. Units may be words, subwords, characters, or bytes. A vocabulary maps those units to integer IDs. An ID is an address, not a magnitude: token seventeen is not numerically more meaningful than token three.

For a teaching example, use whitespace-separated words and a vocabulary fitted on training text. Reserve distinct IDs for padding and unknown tokens. Production tokenizers often need more careful handling of Unicode, punctuation, normalization, and subword boundaries, but the contract remains raw text to ordered IDs.

```python
import torch

training_sentences = ['small models learn', 'models need data']
vocabulary = {'<pad>': 0, '<unk>': 1}
for sentence in training_sentences:
    for token in sentence.split():
        if token not in vocabulary:
            vocabulary[token] = len(vocabulary)

def encode(sentence):
    return torch.tensor([vocabulary.get(token, 1)
                         for token in sentence.split()], dtype=torch.long)

print(vocabulary)
print(encode('small models need examples'))
```

The unseen word becomes the unknown ID. Save the exact vocabulary with the model. Rebuilding it from a different corpus can change addresses while leaving the embedding shape unchanged, producing silent corruption. The tokenizer version and special-token meanings are therefore part of the artifact, just like feature order in tabular learning.

Character tokenization avoids many unknown-word cases and makes a small language-model demonstration self-contained. It produces longer sequences and does not represent language as efficiently as a well-designed subword tokenizer. We will use characters later because their simplicity exposes the training mechanics.

## 5.2 Padding makes a rectangular batch

A tensor batch needs rectangular dimensions, while sentences have different lengths. Padding fills unused positions with a reserved ID. Keep the true lengths or an explicit validity mask so downstream calculations distinguish content from filler.

```python
import torch
from torch.nn.utils.rnn import pad_sequence

sequences = [torch.tensor([2, 3, 4]), torch.tensor([3, 5])]
lengths = torch.tensor([len(sequence) for sequence in sequences])
padded = pad_sequence(sequences, batch_first=True, padding_value=0)
valid = torch.arange(padded.shape[1]).unsqueeze(0) < lengths.unsqueeze(1)
print(padded)
print(valid)
```

The padded tensor has shape `[2, 3]`. The final position in the second row is invalid. The mask is Boolean and has the same token-position shape. A zero embedding for padding does not automatically stop a recurrent model from changing hidden state or an attention model from attending to padding. Mask each mechanism that needs exclusion.

A custom collation function can perform this padding for every batch. Padding to each batch's longest sequence wastes less work than padding every example to a global maximum. Bucketing similar lengths can reduce waste further, but preserve adequate randomization and avoid letting length grouping distort evaluation.

Very long sequences may need truncation or chunking. Either choice changes available context. If the label depends on a discarded portion, truncation introduces an information problem rather than merely a performance optimization. Define what the model is expected to infer from the retained input.

## 5.3 Embeddings turn addresses into learned vectors

An embedding matrix has shape `[V, D]`, where `V` is vocabulary size and `D` is representation width. Looking up token `k` returns row `k`. A batch of token IDs `[B, T]` becomes embedded features `[B, T, D]`.

```python
import torch
from torch import nn

embedding = nn.Embedding(num_embeddings=8, embedding_dim=4, padding_idx=0)
tokens = torch.tensor([[2, 3, 4], [3, 5, 0]])
features = embedding(tokens)
print(features.shape)
print(features[1, 2])
```

The padded row is initialized to zero and is excluded from ordinary embedding-gradient updates under this contract. The other rows are learned parameters. The output vectors can change as the task supplies gradients through the selected rows.

An embedding lookup is equivalent to multiplying a one-hot token vector by an embedding matrix, but avoids constructing the sparse one-hot representation explicitly. This equivalence explains why embeddings are differentiable with respect to matrix entries while token IDs remain discrete. The model learns the representation associated with an address, not a fractional movement between integer addresses.

Distances between embeddings can reflect useful relationships, but their interpretation depends on training. A nearest neighbor in an arbitrary randomly initialized embedding is not a semantic fact. Even a trained geometry may encode task-specific or unwanted patterns rather than a complete theory of word meaning.

## 5.4 A masked average is a useful sequence baseline

Before introducing recurrence or attention, average valid token embeddings and classify the resulting vector. This loses order but gives a simple baseline. It also makes padding arithmetic visible.

```python
import torch
from torch import nn

class MeanClassifier(nn.Module):
    def __init__(self, vocabulary_size, width, classes):
        super().__init__()
        self.embedding = nn.Embedding(vocabulary_size, width, padding_idx=0)
        self.head = nn.Linear(width, classes)
    def forward(self, tokens):
        valid = tokens.ne(0)
        if not valid.any(dim=1).all():
            raise ValueError('Empty sequence is not supported')
        features = self.embedding(tokens)
        summed = (features * valid.unsqueeze(-1)).sum(dim=1)
        averaged = summed / valid.sum(dim=1, keepdim=True)
        return self.head(averaged)

model = MeanClassifier(10, 8, 2)
print(model(torch.tensor([[2, 3, 4], [5, 6, 0]])).shape)
```

The singleton feature axis on the mask permits broadcasting over embedding dimensions. The denominator counts valid tokens in each example. If we averaged across padded width instead, shorter sequences would have systematically smaller representations. That would introduce an unintended dependence on how the batch happened to be padded.

Order-insensitive models can work surprisingly well when the task depends mostly on word presence. They fail on distinctions such as “dog bites person” versus “person bites dog.” A baseline is useful precisely because its limitations are clear and its performance tells us how much additional sequence structure the dataset demands.

## 5.5 Recurrent networks update a state over time

A simple recurrent network computes a hidden state from the current input and previous state:

\[
h_t=\tanh(W_xx_t+W_hh_{t-1}+b).
\]

The same parameters are reused at every position. The hidden state summarizes history through repeated nonlinear updates. This gives a natural ordered model but creates a long chain for gradients and sequential dependence during execution.

Repeated multiplication through time can shrink or amplify gradients. LSTMs and GRUs introduce gates that control information flow, helping preserve useful state. An LSTM maintains both hidden and cell state, with learned gates regulating writing, forgetting, and output. The gates are continuous functions, so training still uses the chain rule.

```python
import torch
from torch import nn

embedding = nn.Embedding(12, 6, padding_idx=0)
lstm = nn.LSTM(input_size=6, hidden_size=8, batch_first=True)
tokens = torch.tensor([[2, 3, 4], [5, 6, 7]])
outputs, (hidden, cell) = lstm(embedding(tokens))
print(outputs.shape, hidden.shape, cell.shape)
```

The output shape is `[2, 3, 8]`. With one unidirectional layer, hidden and cell shapes are `[1, 2, 8]`: layer-direction, batch, hidden features. `batch_first=True` changes input and output sequence layout; it does not make hidden state batch-first. This distinction is a frequent source of indexing errors.

For a sequence classifier, a final valid state can summarize each sequence. For token tagging, apply a head to each output position. A bidirectional model combines past and future context, useful for offline tagging but invalid when a prediction must depend only on the past.

## 5.6 Packed sequences avoid processing padding

Feeding padded sequences through an LSTM and taking the last padded output is wrong when the desired representation is the last actual token state. One option is gathering outputs at each true final index. Another is packing sequences so the recurrent operation skips padded steps.

```python
import torch
from torch import nn
from torch.nn.utils.rnn import pack_padded_sequence, pad_packed_sequence

embedding = nn.Embedding(10, 5, padding_idx=0)
lstm = nn.LSTM(5, 7, batch_first=True)
tokens = torch.tensor([[2, 3, 4], [5, 6, 0]])
lengths = torch.tensor([3, 2], dtype=torch.long)
packed = pack_padded_sequence(embedding(tokens), lengths.cpu(),
                              batch_first=True, enforce_sorted=False)
packed_outputs, (hidden, cell) = lstm(packed)
outputs, restored_lengths = pad_packed_sequence(packed_outputs, batch_first=True)
print(outputs.shape, hidden[-1].shape)
```

Lengths must be positive for this path. CPU lengths satisfy the documented packing contract. `enforce_sorted=False` permits unsorted batches. The final hidden state now corresponds to processed content under the packed sequence semantics, rather than filler steps added to make a rectangle.

Packing adds complexity and may not be the best performance choice for every workload. It is useful when lengths vary substantially and recurrence is the intended architecture. Regardless of implementation, the semantic requirement is that padding must not be mistaken for genuine history.

## 5.7 Token tagging and masked cross entropy

Named-entity recognition assigns a category to each token. A recurrent or transformer encoder can supply contextual features, and a linear head maps each token representation to class logits. If logits have shape `[B, T, C]`, flatten the first two axes and compare with flattened targets.

```python
import torch
from torch import nn

logits = torch.randn(2, 3, 4, requires_grad=True)
labels = torch.tensor([[0, 1, 2], [3, 1, -100]])
loss = nn.functional.cross_entropy(logits.reshape(-1, 4), labels.reshape(-1),
                                    ignore_index=-100)
loss.backward()
print(loss.item(), logits.grad.shape)
```

The ignored target excludes its position from the ordinary mean reduction over valid class-index targets. Ensure at least one valid target exists; an all-ignored mean can be undefined. For dataset-wide loss reporting, accumulate the valid-position loss sum and valid-position count instead of averaging variable-token batch means.

The supplied primer motivates this kind of padded tagging workflow. Modern code can use the built-in ignore-index contract rather than manually indexing labels that include negative padding IDs. Negative tensor indices are valid Python-style indices, so an improvised gather-and-mask implementation can accidentally select the last class before masking.

Token accuracy is not the same as entity-level quality. A named entity spanning several tokens may be incorrect if only one boundary is wrong. Evaluation for real tagging tasks needs the dataset's span and label conventions, not merely a per-position average.

## 5.8 Attention is a weighted lookup

A query describes what information a position is seeking. Keys describe what information source positions offer. Values contain the information to combine. Dot products between a query and keys create scores. Softmax converts those scores into weights, and a weighted sum of values produces the retrieved representation.

For query matrix `Q`, key matrix `K`, and value matrix `V`, scaled dot-product attention is

\[
A=\operatorname{softmax}\left(\frac{QK^\top}{\sqrt{d_k}}+M\right)V.
\]

The mask `M` is zero at allowed locations and negative infinity at forbidden locations in this additive formulation. Softmax is over source positions. The scale counteracts the growth of dot-product variance as key width increases under a simplified independent-feature model.

```python
import math
import torch

queries = torch.tensor([[[1.0, 0.0], [0.0, 1.0]]])
keys = queries.clone()
values = torch.tensor([[[10.0, 0.0], [0.0, 20.0]]])
scores = queries @ keys.transpose(-2, -1) / math.sqrt(2)
weights = scores.softmax(dim=-1)
retrieved = weights @ values
print(weights)
print(retrieved.shape)
```

The output has shape `[1, 2, 2]`. Each query favors the key aligned with it but still mixes both values because softmax gives both finite scores positive weight. Attention is a learned routing calculation, not a literal dictionary lookup and not automatically a human-readable explanation of reasoning.

Self-attention obtains queries, keys, and values from the same sequence through learned projections. Cross-attention obtains queries from one representation and keys and values from another. The latter allows a decoder to retrieve information from an encoder or another modality.

## 5.9 Multihead attention separates learned subspaces

Instead of one large lookup, multihead attention uses several projected subspaces. For model width `D` and `H` heads, a common choice is head width `D / H`. Reshape projections from `[B, T, D]` to `[B, H, T, D/H]`, perform attention per head, then combine heads and apply an output projection.

Each head can learn different relationships, but no rule guarantees a clean semantic role for every head. The benefit is architectural capacity for multiple simultaneous routing patterns. The split requires width divisible by head count under this simple implementation.

```python
import torch
from torch import nn

attention = nn.MultiheadAttention(embed_dim=16, num_heads=4,
                                  batch_first=True, dropout=0.0)
features = torch.randn(2, 5, 16)
padding = torch.tensor([[False, False, False, False, False],
                        [False, False, False, True, True]])
output, _ = attention(features, features, features,
                       key_padding_mask=padding, need_weights=False)
print(output.shape)
```

For this module's `key_padding_mask`, true means exclude the key position. The output still has a row for every query, including padded queries. Mask or ignore those output positions downstream. Preventing attention to padded keys does not automatically remove padded queries from a loss.

## 5.10 Causal masks prevent future-token leakage

An autoregressive language model predicts the next token using only the prefix. During training, many positions are processed together, but a position must not inspect future tokens. A causal mask enforces this restriction within attention.

The direct functional `scaled_dot_product_attention` has an important Boolean convention: true means an attention entry is allowed. This is the opposite of the padding-mask convention in `MultiheadAttention`. Never transfer Boolean masks between APIs without checking their contracts.

```python
import torch
from torch.nn import functional as F

queries = torch.randn(2, 4, 5, 8)
keys = torch.randn(2, 4, 5, 8)
values = torch.randn(2, 4, 5, 8)
output = F.scaled_dot_product_attention(queries, keys, values,
                                        is_causal=True, dropout_p=0.0)
print(output.shape)
```

The four axes are batch, heads, positions, and head features. For equal query and key lengths, `is_causal=True` implements the ordinary prefix restriction. Non-square attention and cached decoding require extra care about alignment. The complete small model below avoids that complexity by recomputing a fixed-length prefix.

The functional operation applies dropout according to the supplied probability, independent of a surrounding module's evaluation flag. A custom module must pass zero dropout during evaluation. Also avoid combining an explicit mask and `is_causal` casually; construct a supported combined mask when padding and causality must both be enforced.

## 5.11 Position information and residual blocks

Self-attention without position information is equivariant to input reordering under corresponding output reordering. Tokens therefore need a way to represent order. Learned position embeddings assign a vector to each allowed position. Sinusoidal and relative-position methods provide other ways to encode order and distance.

Learned absolute positions are straightforward but establish a maximum represented context length in the simple implementation. Supplying a longer sequence without adapting the position scheme is not a harmless batch-size change. Even a scheme that computes positions beyond training length may not generalize there.

A transformer block combines attention with a positionwise feedforward network, residual connections, and normalization. A common pre-normalization pattern is `x = x + attention(norm(x))`, then `x = x + feedforward(norm(x))`. The feedforward network expands feature width, applies a nonlinearity, and projects back. It operates independently at each token after attention exchanges information across positions.

Layer normalization normalizes the feature vector for each token under this setup. Residual paths preserve existing representations while learned branches add corrections. These mechanisms connect directly to the convolutional residual intuition, but the information-exchange operation is attention rather than a spatially local filter.

## 5.12 A complete tiny causal transformer

This program trains a character model on a deliberately tiny repeated text. It demonstrates token shifting, causal attention, next-token loss, and generation. It does not produce a generally capable language model, and its memorization is expected. No external dataset or tokenizer package is required.

```python
import torch
from torch import nn
from torch.nn import functional as F

class CausalAttention(nn.Module):
    def __init__(self, width, heads, dropout=0.1):
        super().__init__()
        if width % heads:
            raise ValueError('Width must be divisible by heads')
        self.heads = heads
        self.head_width = width // heads
        self.qkv = nn.Linear(width, 3 * width)
        self.output = nn.Linear(width, width)
        self.dropout = dropout
    def forward(self, features):
        batch, length, width = features.shape
        query, key, value = self.qkv(features).chunk(3, dim=-1)
        def split(tensor):
            return tensor.reshape(batch, length, self.heads,
                                  self.head_width).transpose(1, 2)
        attended = F.scaled_dot_product_attention(
            split(query), split(key), split(value), is_causal=True,
            dropout_p=self.dropout if self.training else 0.0)
        combined = attended.transpose(1, 2).reshape(batch, length, width)
        return self.output(combined)

class Block(nn.Module):
    def __init__(self, width, heads):
        super().__init__()
        self.norm1 = nn.LayerNorm(width)
        self.attention = CausalAttention(width, heads)
        self.norm2 = nn.LayerNorm(width)
        self.feedforward = nn.Sequential(nn.Linear(width, 4 * width),
                                         nn.GELU(), nn.Linear(4 * width, width))
    def forward(self, features):
        features = features + self.attention(self.norm1(features))
        return features + self.feedforward(self.norm2(features))

class TinyLanguageModel(nn.Module):
    def __init__(self, vocabulary_size, context=24, width=32, heads=4):
        super().__init__()
        self.context = context
        self.tokens = nn.Embedding(vocabulary_size, width)
        self.positions = nn.Embedding(context, width)
        self.blocks = nn.Sequential(Block(width, heads), Block(width, heads))
        self.norm = nn.LayerNorm(width)
        self.head = nn.Linear(width, vocabulary_size)
    def forward(self, token_ids):
        batch, length = token_ids.shape
        if length > self.context:
            raise ValueError('Sequence exceeds context')
        positions = torch.arange(length, device=token_ids.device)
        features = self.tokens(token_ids) + self.positions(positions)
        return self.head(self.norm(self.blocks(features)))

@torch.no_grad()
def generate(model, prefix, additional_tokens, temperature=1.0):
    if temperature <= 0:
        raise ValueError('Temperature must be positive')
    model.eval()
    sequence = prefix.clone()
    for _ in range(additional_tokens):
        logits = model(sequence[:, -model.context:])[:, -1, :]
        probabilities = (logits / temperature).softmax(dim=-1)
        next_token = torch.multinomial(probabilities, num_samples=1)
        sequence = torch.cat([sequence, next_token], dim=1)
    return sequence

def main():
    torch.manual_seed(53)
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    text = ('small models learn from data. data shapes learning. ' * 50)
    characters = sorted(set(text))
    to_id = {character: index for index, character in enumerate(characters)}
    data = torch.tensor([to_id[character] for character in text], dtype=torch.long)
    split = int(0.9 * len(data))
    training, validation = data[:split], data[split:]
    model = TinyLanguageModel(len(characters)).to(device)
    optimizer = torch.optim.AdamW(model.parameters(), lr=2e-3)
    def batch(source):
        starts = torch.randint(0, len(source) - model.context, (8,))
        inputs = torch.stack([source[start:start + model.context] for start in starts])
        targets = torch.stack([source[start + 1:start + model.context + 1] for start in starts])
        return inputs.to(device), targets.to(device)
    for step in range(150):
        model.train()
        inputs, targets = batch(training)
        optimizer.zero_grad(set_to_none=True)
        logits = model(inputs)
        loss = F.cross_entropy(logits.reshape(-1, len(characters)), targets.reshape(-1))
        loss.backward()
        optimizer.step()
        if step % 50 == 0:
            model.eval()
            with torch.no_grad():
                val_inputs, val_targets = batch(validation)
                val_logits = model(val_inputs)
                val_loss = F.cross_entropy(val_logits.reshape(-1, len(characters)),
                                            val_targets.reshape(-1))
            print(step, loss.detach().item(), val_loss.item())
    prefix = torch.tensor([[to_id['s']]], device=device)
    generated = generate(model, prefix, 80)
    print(''.join(characters[index] for index in generated[0].cpu().tolist()))

if __name__ == '__main__':
    main()
```

Each training input starts at one character, and its target starts one character later. The model's output at position `t` predicts the following character. Causal attention prevents that position from reading the answer directly from a future input position. Training all positions together is efficient because each receives its own prefix-constrained objective.

The repeated corpus makes the validation text highly redundant with training. This is explicitly a mechanics demonstration, not a valid estimate of language generalization. A real corpus should be split by independent documents or sources and deduplicated appropriately. The code includes validation to show mode handling and objective calculation, not to make a performance claim.

Generation takes only the final position's logits, samples one character, appends it, and repeats. Cropping to the context window avoids position-table overflow. Recomputing the prefix is simple but inefficient compared with a key-value cache. The cache is an inference optimization that must preserve exactly which positions and causal relationships are represented.

## 5.13 Temperature, sampling, and perplexity

Temperature divides logits before softmax. Lower positive values concentrate probability on larger logits; higher values spread it more evenly. This changes sampling behavior, not the fitted parameters. Greedy decoding chooses the largest logit and is deterministic given the computation, while multinomial sampling draws from the probability distribution.

Top-k and nucleus sampling restrict the candidate distribution before drawing. These can improve some generation behavior but do not guarantee factuality or coherence. A language model learns a distribution over token sequences under its objective; correctness in a downstream application requires additional task design and evaluation.

Perplexity is the exponential of average negative log-likelihood when natural logarithms are used. It summarizes how much probability the model assigns to observed tokens. Compare perplexities only under compatible tokenization, evaluation data, and masking conventions. A character-level perplexity is not directly comparable to a subword-level perplexity.

A mean over sequence means gives every sequence equal influence. A global token mean gives every valid token equal influence. For language-model likelihood reporting, the latter is often intended. Accumulate summed losses and valid-token counts across batches, especially when context lengths vary.

## 5.14 Sequence-model debugging

A suspiciously low training loss can mean future-token leakage. Check target shifting, causal masks, and whether the input includes the target in an accessible position. An attention matrix with the expected shape can still encode the wrong allowed positions. Test a tiny sequence where changing a future token must not alter earlier outputs in evaluation mode.

Padding bugs often appear only when sentences share a batch with longer sentences. Compare a sentence's prediction alone with its prediction in a padded batch under evaluation. They should agree within appropriate numerical tolerance for a model intended to ignore padding. If they differ substantially, inspect attention masks, pooling denominators, and recurrent final-state selection.

If all predictions favor a common token, inspect class frequencies, token mapping, learning rate, and whether ignored positions dominate the objective. If generation is repetitive, distinguish a tiny repetitive dataset from an implementation error. A small model trained on repeated phrases should not be expected to invent broad linguistic ability.

## 5.15 A tiny attention calculation without hidden dimensions

Suppose a query has scores zero and the natural logarithm of three against two source positions. Exponentiating produces one and three. Softmax therefore assigns weights one quarter and three quarters. If the two scalar values are ten and twenty, the retrieved result is `0.25 × 10 + 0.75 × 20 = 17.5`.

This calculation reveals what attention does and does not do. It creates a content-dependent weighted combination. The output can lie between source values in this simple scalar example. With learned projections and a subsequent output transformation, the full network can compute much richer functions. The weight alone should not be interpreted as the complete contribution of a source token to the final prediction because values, residual paths, and later layers also matter.

If the second source position is forbidden, an additive mask replaces its score with negative infinity before softmax. Its exponential becomes zero, leaving all mass on the first source. Masking after softmax by simply zeroing a weight would instead leave weights that no longer sum to one unless explicitly renormalized. The placement of the mask is part of the mathematical definition.

If every source is forbidden for a query, the normalization can become undefined. Some implementations have special handling, but a model should avoid relying on unspecified behavior. Ensure every meaningful query has at least one permitted key, and ignore padded query outputs consistently. This is especially important when combining padding, causal masking, and entirely empty sequences.

## 5.16 Combining padding and causality explicitly

For functional attention, let `valid_keys` have shape `[B, T]`, with true for actual tokens. Let a lower-triangular Boolean matrix of shape `[T, T]` mark causal permission. Their logical conjunction can create an allowed mask broadcastable to `[B, H, T, T]`.

```python
import torch
from torch.nn import functional as F

batch, heads, length, width = 2, 2, 4, 3
query = torch.randn(batch, heads, length, width)
key = torch.randn_like(query)
value = torch.randn_like(query)
valid_keys = torch.tensor([[True, True, True, True],
                           [True, True, False, False]])
causal = torch.ones(length, length, dtype=torch.bool).tril()
allowed = causal[None, None, :, :] & valid_keys[:, None, None, :]
output = F.scaled_dot_product_attention(query, key, value,
                                        attn_mask=allowed, dropout_p=0.0)
output = output * valid_keys[:, None, :, None]
print(output.shape)
```

The batch dimension permits different padding patterns. The singleton head dimension shares the permission pattern across heads. The final multiplication zeroes padded query outputs, while the attention mask excludes padded keys. The example uses right padding and nonempty sequences, so real queries retain a valid prefix.

A left-padded causal sequence needs additional care because early padded queries can have no allowed valid keys. Position numbering also needs a defined policy. Rather than treating every padding arrangement as interchangeable, establish the tokenizer, batching convention, and generation convention together. A consistent simple design is easier to validate than a flexible design with untested combinations.

## 5.17 Encoders, decoders, and encoder-decoder systems

An encoder commonly allows each token to access all valid tokens in the input sequence. This suits tasks where the entire observation is available, such as document classification or offline entity tagging. A causal decoder restricts each position to its prefix, supporting next-token generation. An encoder-decoder system adds cross-attention from generated output positions to an encoded input.

These names refer to information flow, not merely class names in a library. A module called a decoder may contain self-attention and cross-attention, while a decoder-only language model uses causal self-attention without a separate source encoder. Read the actual dependencies to understand what information is available.

For translation, the encoder processes a source sentence, and the decoder predicts a target sequence. During teacher-forced training, the decoder receives previous target tokens and predicts the next ones. The causal mask prevents access to future target tokens, while cross-attention can inspect the valid source representation. At inference, previous target tokens are the model's own outputs, creating a difference from training that evaluation must account for.

For time-series forecasting, a similar distinction matters. An offline encoder can use the whole historical window, but it must not receive future measurements unavailable at the forecast time. Known future covariates, such as a calendar, are a separate input category from unknown future outcomes. Masking cannot correct a dataset that already placed unavailable information into the input features.

## 5.18 Fine-tuning a pretrained language model conceptually

A pretrained model arrives with more than a parameter matrix. Its tokenizer, special-token IDs, architecture configuration, context policy, and output interpretation must agree. Replacing one component independently can make the system invalid even when tensor dimensions happen to match.

For classification, a common adaptation obtains a pooled representation and trains a task head. Pooling may use a designated summary token, the final valid token, or a masked average, depending on architecture and pretraining. Choosing the first tensor row by habit is not a universal pooling rule. The representation must correspond to the intended model contract.

Full fine-tuning updates all selected parameters. Parameter-efficient adaptation updates a smaller introduced set, such as low-rank matrices added to existing projections. A low-rank update writes a correction as `B @ A`, reducing trainable parameter count when the rank is small. It does not reduce all activation memory automatically, and base-model storage still matters.

Compare adaptation methods under the same task split and inference procedure. A smaller trainable parameter count is useful for memory and artifact management, but task quality, latency, supported kernels, and deployment compatibility also matter. The framework mechanisms learned here let you understand these methods without depending on an unexplained high-level training wrapper.

## 5.19 Why attention can be expensive

For sequence length `T`, full attention forms pairwise relationships between query and key positions, giving a conceptual score matrix with `T²` entries per head. Doubling sequence length therefore increases this part of computation and naive intermediate storage by roughly four, holding other dimensions fixed. The feedforward network has a different scaling with width and length.

Fused attention implementations can avoid materializing the entire score matrix in ordinary memory and improve numerical and memory behavior. This does not make the underlying pairwise computation free. Hardware, dtype, mask form, and shape determine which implementation is available. Prefer the public functional operation over reimplementing a large naive attention matrix when performance matters, after validating semantics.

For generation, a key-value cache stores previous projected keys and values so each new token does not recompute every prefix projection. Cache growth consumes memory proportional to retained context and layer count. Quantization, grouped-query attention, sliding windows, and other techniques change this tradeoff, but each introduces architecture or approximation choices that require their own evaluation.

The tiny model intentionally omits caching so its correctness can be understood from a straightforward prefix computation. A good optimization preserves that reference behavior within an appropriate tolerance before it is trusted for speed.

## 5.20 An optional causal invariance test

A useful property test changes tokens strictly after a chosen position and verifies that earlier logits remain unchanged in evaluation mode for a causal model. Use the `TinyLanguageModel` class from Section 5.12 in the same file; the following is an intentional continuation fragment.

```python
model = TinyLanguageModel(vocabulary_size=12)
model.eval()
original = torch.tensor([[1, 2, 3, 4, 5]])
changed = torch.tensor([[1, 2, 3, 9, 8]])
with torch.no_grad():
    first = model(original)
    second = model(changed)
assert torch.allclose(first[:, :3], second[:, :3], atol=1e-6, rtol=1e-5)
```

This checks information flow rather than reproducing the implementation line by line. It can catch a missing causal mask, an incorrectly oriented mask, or an unintended operation that mixes future positions. It does not prove every aspect of the model correct. Token shifting, padding, vocabulary identity, and objective reductions need their own checks.

The broader lesson is to test properties implied by the mathematics. A padded sentence should preserve its content representation. A causal prefix should not depend on future tokens. A probability distribution should sum to one over valid candidates. These properties give you a practical bridge from theory to dependable code.

## 5.21 Choosing a sequence model with evidence

A masked embedding average is cheap and easy to inspect. An LSTM introduces ordered state with sequential processing. Full attention permits direct interaction between distant positions but has a different length-dependent cost. These are engineering alternatives with different assumptions, rather than a historical ranking in which every newer architecture automatically wins.

For a short classification task dominated by keyword presence, the simple baseline may be adequate. For a streaming system with a strict state budget, recurrence can be attractive. For tasks requiring flexible long-range interactions and effective parallel training, attention can be useful. Evaluate under the actual latency, memory, data, and quality requirements.

Measure the full pipeline, including tokenization and padding. A fast network can still be part of a slow system if preprocessing dominates. Similarly, a model with lower average loss may not improve the decision metric that matters. Keep architectural comparisons tied to a stated question and a consistent evaluation population.

By this point, the central ideas should connect: tokenization establishes identities, embeddings provide continuous parameters, sequence operations exchange information, masks enforce availability, and an objective defines the learning signal. The framework automates derivatives through that system, but you define its meaning. The next chapter changes the objective and differentiation pattern while retaining this same disciplined separation of representation, information flow, and evidence.

## 5.22 A low-rank adapter from first principles

An affine projection stores a weight matrix with output-by-input shape. Instead of updating that whole matrix, a low-rank adapter adds a correction factored into two smaller matrices. The forward calculation becomes the frozen base output plus a scaled `B(A(x))` branch. If the rank is much smaller than both widths, the branch has many fewer trainable weights.

```python
import torch
from torch import nn

class LowRankLinear(nn.Module):
    def __init__(self, base, rank=2, alpha=2.0):
        super().__init__()
        if rank <= 0:
            raise ValueError('Rank must be positive')
        self.base = base
        for parameter in base.parameters():
            parameter.requires_grad_(False)
        self.down = nn.Linear(base.in_features, rank, bias=False)
        self.up = nn.Linear(rank, base.out_features, bias=False)
        nn.init.zeros_(self.up.weight)
        self.scale = alpha / rank
    def forward(self, features):
        return self.base(features) + self.scale * self.up(self.down(features))

base = nn.Linear(16, 12)
adapted = LowRankLinear(base)
features = torch.randn(3, 16)
assert torch.allclose(adapted(features), base(features))
loss = adapted(features).square().mean()
loss.backward()
print(sum(parameter.numel() for parameter in adapted.parameters()
          if parameter.requires_grad))
```

The zero-initialized output branch makes the initial adapted function equal the base function. The other branch is not also initialized to zero; zeroing both factors would obstruct the initial learning signal. On the first backward pass, the output factor can receive a gradient while the input factor may initially have zero gradient. Subsequent updates allow both to learn.

This is the core low-rank projection mechanism, not a complete pretrained-language-model adapter package. Real integration must select projections, preserve dtype and device, save adapter configuration, and keep the matching base-model identity. The reduction in trainable weights does not remove the need for activations through frozen operations when gradients must reach adapters deeper in the model.

## Sources

The [LSTM contract](https://docs.pytorch.org/docs/2.15/generated/torch.nn.LSTM.html), [functional scaled dot-product attention](https://docs.pytorch.org/docs/2.15/generated/torch.nn.functional.scaled_dot_product_attention.html), and [MultiheadAttention](https://docs.pytorch.org/docs/stable/generated/torch.nn.MultiheadAttention) support the API-specific notes. The supplied [primer](https://aman.ai/primers/pytorch/) motivates the padded token-tagging use case. Accessed November 12, 2026. All teaching programs above are original. The low-rank adaptation section also references Hu and colleagues, [LoRA](https://arxiv.org/abs/2106.09685), for method provenance.
