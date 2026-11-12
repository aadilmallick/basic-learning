# Lesson 4 — Neural architectures for images, sequences, and generation

[Previous lesson](03-keras-data-and-reliable-experiments.md) · [Course index](../README.md) · [Next lesson](05-graphs-custom-training-and-deployment.md)

## 1. Architecture expresses an assumption about structure

A dense network treats its input as a feature vector. That can work for many tasks, but it ignores useful relationships unless it learns them from data. Neighboring image pixels often interact locally. Words occur in order. Some token relationships span an entire document. An architecture encodes assumptions that make these relationships easier to represent.

The goal is not to memorize a catalog of layers. For each family, ask what interaction it computes, which parameters it shares, what shapes it expects, and where its assumptions can fail. Those questions connect architecture directly to the mathematical and data contracts established earlier.

This chapter moves from convolution to recurrence, then attention, then generative objectives. The examples are deliberately small and use synthetic inputs unless explicitly stated otherwise. A forward pass establishes shape compatibility, not useful learned behavior. Training useful systems requires representative data and the evaluation workflow from Lesson 3.

## 2. Why flattening images is expensive

A color image of size `64 × 64` contains `12,288` scalar channel values. Flattening it and connecting to 256 hidden units requires `12,288 × 256 + 256 = 3,145,984` parameters. Each pixel position gets independent weights, even if similar patterns appear at different locations.

A convolution instead applies the same small filter across spatial positions. A `3 × 3` filter looking at three channels has 27 weights. Sixteen output filters require `3 × 3 × 3 × 16 + 16 = 448` parameters including biases. The parameter savings come from local connectivity and spatial sharing.

Sharing is an inductive bias: a useful local pattern may be useful in several parts of an image. It does not mean every vision problem is translation-invariant. Pixel position may matter in medical imaging, satellite data, or structured documents. Architecture should help the task rather than erase needed information.

A convolutional feature map records where a learned local pattern responds. The filters begin as numerical weights, not preassigned edge detectors. Training can produce edge-like early features in some settings, but there is no guarantee every channel has a simple visual interpretation.

## 3. Derive one convolution output

Take a one-channel image patch

\[
\begin{bmatrix}1&2\\3&4\end{bmatrix}
\]

and a filter

\[
\begin{bmatrix}1&0\\0&-1\end{bmatrix}.
\]

Multiply corresponding entries and sum to get `1 - 4 = -3`. Add the filter's bias if present. Moving the filter to another patch repeats the same calculation with the same parameters. Common deep learning implementations use cross-correlation, meaning they do not spatially reverse the kernel as the strict mathematical convolution definition would.

```python
import tensorflow as tf

image = tf.constant([[[[1.0], [2.0]], [[3.0], [4.0]]]])
kernel = tf.constant([[[[1.0]], [[0.0]]], [[[0.0]], [[-1.0]]]])
output = tf.nn.conv2d(image, kernel, strides=1, padding="VALID")
print(output.shape)          # (1, 1, 1, 1)
print(output.numpy().item()) # -3.0
```

The image shape is `(batch, height, width, input_channels)`. The kernel shape is `(kernel_height, kernel_width, input_channels, output_channels)`. With one two-by-two image and a two-by-two filter under valid padding, only one spatial placement exists.

With multiple input channels, the filter spans all channels and sums their contributions into one output channel. Multiple filters produce multiple output channels. A channel is therefore a feature coordinate at each spatial location, not necessarily a red, green, or blue channel after the first layer.

## 4. Stride, padding, pooling, and receptive fields

Stride controls how far a filter moves between placements. A stride of two reduces spatial resolution more quickly than a stride of one. Valid padding uses only placements fully inside the input. Same padding adds boundary values so output dimensions follow a stride-dependent size rule; with stride one, spatial size is preserved.

For valid convolution with effective kernel size `K`, input size `N`, and stride `S`, the output size is `floor((N - K) / S) + 1`. Dilation increases the effective kernel spacing and therefore changes `K`. Derive sizes one axis at a time instead of relying on visual intuition for every architecture.

Max pooling takes the largest value in a local region. Average pooling computes a local mean. Neither requires learned kernel weights in its basic form. Pooling and strided convolutions can reduce computation and make representations less sensitive to small spatial shifts, but they also discard spatial detail.

A unit's receptive field is the region of input that can influence it. Stacking local layers expands that region. Two stride-one three-by-three convolutions have a five-by-five nominal receptive field in the interior. Adding strides changes the spacing of influence and grows the receptive field faster. The effective learned influence can be concentrated within that nominal region.

Global average pooling averages each channel over the entire spatial grid. It turns `(batch, height, width, channels)` into `(batch, channels)`. This supports image classification with fewer parameters than flattening. It is less appropriate when the output must preserve precise position, as in segmentation.

## 5. A small convolutional classifier

```python
import tensorflow as tf
from tensorflow import keras

keras.utils.set_random_seed(9)
inputs = keras.Input(shape=(16, 16, 3))
features = keras.layers.Conv2D(8, 3, padding="same", activation="relu")(inputs)
features = keras.layers.MaxPooling2D(pool_size=2)(features)
features = keras.layers.Conv2D(16, 3, padding="same", activation="relu")(features)
features = keras.layers.GlobalAveragePooling2D()(features)
logits = keras.layers.Dense(3)(features)
model = keras.Model(inputs, logits)
model.compile(
    optimizer=keras.optimizers.Adam(0.001),
    loss=keras.losses.SparseCategoricalCrossentropy(from_logits=True),
    metrics=[keras.metrics.SparseCategoricalAccuracy()],
    jit_compile=False,
)
print(model(tf.zeros([2, 16, 16, 3]), training=False).shape)  # (2, 3)
```

The first convolution preserves the sixteen-by-sixteen grid and creates eight feature channels. Pooling halves each spatial dimension to eight. The second convolution creates sixteen channels. Global pooling produces sixteen numbers per image, and the final dense layer produces three logits.

The code compiles and runs a forward pass; it does not claim to recognize real objects. To train it, provide image-label batches satisfying the contract and validate on a meaningful split. Normalized input scale must match the pipeline. A correct shape does not establish that images have the intended orientation, channel order, or target mapping.

For segmentation, replace the global pooled classification head with spatial outputs and an appropriate upsampling path. For object detection, outputs include locations as well as class information and require a more complex objective and matching strategy. These are task-specific extensions, not just larger class counts.

## 6. Transfer learning reuses a learned representation

A pretrained network has already learned parameters from a source task. Transfer learning uses part of that representation for a related target task. It is especially useful when target data is limited and source features capture relevant structure.

A common workflow is to freeze the pretrained base, train a new head, then unfreeze some base layers and continue with a smaller learning rate. Freezing means those parameters are excluded from ordinary gradient updates. It does not automatically mean every stateful behavior uses inference mode; trainability and runtime mode are related but distinct concepts.

The following construction avoids a download by using `weights=None`. That makes it a shape and API demonstration, not actual transfer learning. For a real transfer experiment, change to `weights="imagenet"` with network access and use suitable target data.

```python
import tensorflow as tf
from tensorflow import keras

base = keras.applications.MobileNetV2(
    input_shape=(32, 32, 3), include_top=False, weights=None,
)
base.trainable = False
inputs = keras.Input(shape=(32, 32, 3))
# Contract: callers supply RGB values in [0, 255].
normalized = keras.layers.Rescaling(1.0 / 127.5, offset=-1.0)(inputs)
features = base(normalized, training=False)
features = keras.layers.GlobalAveragePooling2D()(features)
logits = keras.layers.Dense(2)(features)
model = keras.Model(inputs, logits)
print(model(tf.zeros([1, 32, 32, 3])).shape)
```

For an actual pretrained MobileNetV2, the rescaling matches its expected negative-one-to-one input range. Other pretrained families can use different conventions, including internal preprocessing. Read the exact model documentation rather than attaching a universal image normalizer.

After changing `base.trainable`, recompile the enclosing model with a suitable optimizer configuration. Keeping the base call in inference mode can preserve batch-normalization statistics during fine-tuning. A small target dataset can otherwise corrupt useful stored statistics. Transfer quality still depends on source-target similarity; pretrained features are not guaranteed to help every domain.

## 7. Residual connections preserve an easier route

A residual block computes something like \(h_{\text{out}}=h+F(h)\). Instead of requiring the block to learn a complete transformation from scratch, it can learn a correction around the identity. If `F` is near zero, the block approximately preserves its input.

This creates a direct gradient path through the addition. It does not eliminate all vanishing or exploding gradients, but it changes the optimization geometry in a useful way for many deep networks. Residual connections appear in both convolutional architectures and transformers.

The two added tensors must have compatible shapes. If channel count or spatial resolution changes, a projection can transform the shortcut to match the residual branch. Broadcasting should not accidentally stand in for a deliberate projection.

```python
import tensorflow as tf
from tensorflow import keras

inputs = keras.Input(shape=(8, 8, 16))
residual = keras.layers.Conv2D(16, 3, padding="same", activation="relu")(inputs)
residual = keras.layers.Conv2D(16, 3, padding="same")(residual)
outputs = keras.layers.Activation("relu")(
    keras.layers.Add()([inputs, residual])
)
block = keras.Model(inputs, outputs)
print(block(tf.zeros([2, 8, 8, 16])).shape)
```

The identity branch has no additional parameters. The learned branch has two convolutions. Their outputs agree in shape, so addition has the intended elementwise meaning. This small block illustrates the structural idea without claiming to reproduce every detail of a particular ResNet architecture.

## 8. Embeddings turn IDs into learned features

An integer word ID is an address. An embedding matrix associates that address with a vector. With vocabulary size `V` and embedding width `D`, the table contains `V × D` trainable values. Looking up token IDs selects rows.

```python
import tensorflow as tf
from tensorflow import keras

embedding = keras.layers.Embedding(input_dim=20, output_dim=4, mask_zero=True)
token_ids = tf.constant([[2, 3, 0], [4, 5, 6]])
vectors = embedding(token_ids)
print(vectors.shape)  # (2, 3, 4)
print(embedding.compute_mask(token_ids).numpy())
```

The first sequence has a padded position marked false in the mask. The embedding values themselves remain vectors; `mask_zero=True` does not mean the row-zero vector is guaranteed to be all zeros. It supplies metadata to mask-aware downstream layers.

Gradients update selected embedding rows according to the downstream task. Similar vectors can emerge when tokens play similar roles, but the geometry is learned under the objective and data. ID adjacency has no intrinsic meaning: token two is not necessarily semantically closer to token three than token nineteen.

Pooling embeddings can create a simple document representation. Mean pooling loses order, making it useful as a baseline but unable to distinguish every reordered sentence. A recurrent or attention-based model represents interactions that a bag-of-embeddings average cannot capture directly.

## 9. Recurrence carries state across a sequence

A recurrent network updates a hidden state at each step:

\[
h_t=\tanh(x_tW_x+h_{t-1}W_h+b).
\]

The current state depends on the current input and the previous state. The same transition parameters are reused across time. This sharing allows the model to process different sequence lengths without learning a separate transition for every position.

The state is a learned summary, not a perfect memory of everything seen. Repeated transformations can lose information and create difficult gradient paths over long sequences. LSTM and GRU architectures introduce gates that control how information is retained and updated.

An LSTM maintains both a cell state and a hidden output, with learned gates regulating forgetting, writing, and exposure. The core intuition is controlled additive memory flow. A GRU uses a related gated design with a different state structure. Neither guarantees that arbitrarily distant dependencies will be learned from limited data.

```python
import tensorflow as tf
from tensorflow import keras

inputs = keras.Input(shape=(None,), dtype="int32")
vectors = keras.layers.Embedding(100, 16, mask_zero=True)(inputs)
summary = keras.layers.GRU(24)(vectors)
logits = keras.layers.Dense(3)(summary)
classifier = keras.Model(inputs, logits)
print(classifier(tf.constant([[2, 3, 0], [4, 5, 6]])).shape)  # (2, 3)
```

The `None` in the input shape allows different sequence lengths across calls, though examples inside a dense batch still need compatible padded lengths. The GRU consumes the sequence and returns one summary vector per example. With `return_sequences=True`, it returns an output at every time position instead.

A bidirectional recurrent layer sees both preceding and following context. That is appropriate for full-document classification or tagging when the entire input is available. It leaks future information in a causal next-step predictor if used without changing the task definition.

## 10. Sequence tagging requires masked objectives

For tagging, each real token has a class. The model outputs `(batch, time, classes)`, while labels have shape `(batch, time)`. Padding is a storage device, so it should not contribute to the learning objective.

```python
import tensorflow as tf
from tensorflow import keras

labels = tf.constant([[1, 2, -1], [0, 1, 2]], dtype=tf.int32)
logits = tf.constant([
    [[0.0, 2.0, 0.0], [0.0, 0.0, 2.0], [4.0, 0.0, 0.0]],
    [[2.0, 0.0, 0.0], [0.0, 2.0, 0.0], [0.0, 0.0, 2.0]],
])
valid = labels >= 0
safe_labels = tf.where(valid, labels, tf.zeros_like(labels))
per_token = keras.losses.sparse_categorical_crossentropy(
    safe_labels, logits, from_logits=True,
)
weights = tf.cast(valid, per_token.dtype)
loss = tf.math.divide_no_nan(
    tf.reduce_sum(per_token * weights), tf.reduce_sum(weights),
)
print(loss.numpy())
```

There are five real tokens, so the denominator is five. Replacing padded labels before calling the loss avoids an invalid class index. `divide_no_nan` defines a zero result for a fully padded batch, but such a batch should usually be filtered or investigated because it contains no supervision.

The input mask and loss mask have different jobs. The input mask prevents some layers from treating padding as real context. The loss mask prevents padded targets from affecting optimization and metrics. One does not automatically guarantee the other in every custom model.

For named entity recognition, subword tokenization introduces an additional alignment decision. A word can split into several subwords. Decide whether labels are repeated, assigned only to the first subword, or represented by another scheme. Preserve that convention through training, decoding, and evaluation.

## 11. Attention retrieves context using learned compatibility

Recurrence compresses previous context into a state. Attention instead compares a query with a collection of keys and combines associated values. A useful analogy is a weighted retrieval operation: the query expresses what information is wanted, the keys determine relevance, and the values supply the content to combine.

The analogy has limits. These are learned vectors, not necessarily human-readable database fields. Attention weights depend on the model's parameterization and current inputs. A large weight is not automatically a faithful causal explanation of a prediction.

Scaled dot-product attention is

\[
A=\operatorname{softmax}\left(\frac{QK^\top}{\sqrt{d_k}}+M\right),
\qquad O=AV.
\]

Rows of `Q` correspond to query positions. Rows of `K` and `V` correspond to source positions. The score matrix has one source score per query. Softmax normalizes across source positions so each query receives a weighted mixture of value vectors.

The scale by the square root of key width controls score magnitude under a rough variance argument. If query and key components have comparable independent variance, a sum of `d_k` products has variance that grows with `d_k`. Scaling helps keep softmax away from extreme saturation as width grows. The independence assumptions are a heuristic motivation, not a universal description of learned features.

## 12. Compute attention on a tiny example

```python
import tensorflow as tf

queries = tf.constant([[[1.0, 0.0]]])
keys = tf.constant([[[1.0, 0.0], [0.0, 1.0]]])
values = tf.constant([[[10.0, 0.0], [0.0, 20.0]]])
scores = tf.matmul(queries, keys, transpose_b=True)
scores = scores / tf.sqrt(tf.cast(tf.shape(keys)[-1], tf.float32))
weights = tf.nn.softmax(scores, axis=-1)
context = tf.matmul(weights, values)
print(weights.numpy())
print(context.numpy())
```

There is one query and two source positions. The first key aligns more strongly with the query, so it receives more weight. The context is a mixture of both value vectors, not a hard selection of one row. Softmax makes the weights sum to one across the two sources.

For self-attention, queries, keys, and values are projections of the same input sequence. For cross-attention, queries come from one representation and keys and values from another. A decoder can query an encoder's outputs, while a document's tokens can query one another through self-attention.

Multihead attention learns several projection sets. Different heads can represent different compatibility patterns, and their outputs are combined. `key_dim` in Keras describes the key width per head, so four heads with key dimension eight use a different internal arrangement from one head with key dimension eight.

## 13. Padding and causal masks prevent different mistakes

A padding mask prevents attention to positions that are merely storage filler. A causal mask prevents a position from accessing future positions when predicting autoregressively. A decoder may require both.

For Keras `MultiHeadAttention`, a boolean attention mask uses true for allowed attention. For queries of length `T` and keys of length `S`, the conceptual shape is `(batch, T, S)`. Build it from input validity rather than guessing dimensions after an error.

```python
import tensorflow as tf
from tensorflow import keras

token_ids = tf.constant([[2, 3, 0], [4, 5, 6]])
valid = token_ids != 0
vectors = keras.layers.Embedding(20, 8)(token_ids)
allowed = tf.logical_and(valid[:, :, None], valid[:, None, :])
attention = keras.layers.MultiHeadAttention(num_heads=2, key_dim=4)
context = attention(
    query=vectors, value=vectors, key=vectors,
    attention_mask=allowed, use_causal_mask=True,
)
print(context.shape)  # (2, 3, 8)
```

The query and key validity terms exclude padding on both axes. Fully masked query rows are not useful predictions; downstream loss masking must still exclude them. The model must never rely on padded-row numerical values having some universal semantic meaning.

Causality is a property of the full computation. A causal attention mask cannot repair future information already leaked through feature construction, bidirectional preprocessing, or an incorrectly shifted target. Trace information availability from raw data through the output objective.

## 14. Position and transformer blocks

Self-attention without positional information treats token arrangements symmetrically under corresponding permutations. Natural language usually depends on order, so transformers add or otherwise encode position. Learned absolute embeddings, sinusoidal encodings, and relative position methods are different approaches with different extrapolation properties.

A basic transformer block combines attention, a residual connection, normalization, a position-wise feed-forward network, and another residual connection. The feed-forward network applies the same small dense network independently at each position. Attention mixes information across positions; the feed-forward network transforms feature coordinates within positions.

Layer normalization normalizes features within each example-position rather than using a batch-wide estimate. This makes its behavior different from batch normalization. The placement of normalization before or after sublayers changes optimization behavior; the example below uses a pre-normalized structure.

```python
import tensorflow as tf
from tensorflow import keras

sequence = tf.random.normal([2, 5, 16])
normalizer_one = keras.layers.LayerNormalization(epsilon=1e-5)
attention = keras.layers.MultiHeadAttention(num_heads=2, key_dim=8)
normalizer_two = keras.layers.LayerNormalization(epsilon=1e-5)
feed_forward = keras.Sequential([
    keras.layers.Dense(32, activation="gelu"),
    keras.layers.Dense(16),
])
normalized = normalizer_one(sequence)
hidden = sequence + attention(normalized, normalized, use_causal_mask=True)
output = hidden + feed_forward(normalizer_two(hidden))
print(output.shape)  # (2, 5, 16)
```

This is a block mechanics demonstration. A complete token model also needs token embeddings, positional information, an output head, masks, and an objective. The included `examples/attention_demo.py` supplies a complete tiny forward model with explicit padding and positions.

Ordinary full attention creates a score matrix proportional to sequence length squared. Doubling length roughly quadruples the score-matrix element count for fixed batch and heads. Practical long-context systems may use optimized attention implementations or alternative structures; changing the implementation does not remove the need to understand its actual memory and computational behavior.

## 15. Autoregressive language modeling is shifted prediction

An autoregressive model factors a sequence probability as

\[
p(t_1,\ldots,t_T)=\prod_{j=1}^{T}p(t_j\mid t_1,\ldots,t_{j-1}).
\]

Training exposes a prefix and asks for the next token at every position. For a token row `[start, a, b, end]`, inputs are `[start, a, b]` and targets `[a, b, end]`. The causal mask ensures the representation at a position cannot inspect later input positions.

This parallel training method is often called teacher forcing: the model receives true preceding tokens rather than its own previously generated guesses. In inference, it generates one token, appends it to the context, and repeats. The difference between training prefixes and self-generated prefixes can affect behavior.

```python
import tensorflow as tf

complete_sequences = tf.constant([[1, 4, 5, 2, 0], [1, 7, 2, 0, 0]])
inputs = complete_sequences[:, :-1]
targets = complete_sequences[:, 1:]
valid_targets = targets != 0
print(inputs.numpy())
print(targets.numpy())
print(valid_targets.numpy())
```

Token zero is padding, one start, and two end in this invented vocabulary. End tokens are real training targets. Padding is excluded. The loss is cross-entropy over the vocabulary at each valid target position, reduced according to the intended token or sequence weighting.

Perplexity is the exponential of mean negative log likelihood when natural logarithms are used. It summarizes how much probability the model assigns to observed tokens under its tokenizer and evaluation corpus. Perplexities from different tokenizations are not directly comparable without care because the prediction units changed.

## 16. Sampling controls generation without retraining

Greedy decoding always chooses the largest logit. It is deterministic for fixed outputs but can produce repetitive or locally myopic sequences. Sampling draws from a distribution and can produce variety. Temperature rescales logits before softmax:

\[
p_k(T)=\operatorname{softmax}(z/T)_k.
\]

A lower positive temperature sharpens the distribution; a higher temperature flattens it. Temperature zero is not a valid direct division operation and is usually treated separately as greedy selection.

```python
import tensorflow as tf

logits = tf.constant([[2.0, 1.0, -1.0]])
temperature = 0.8
sample = tf.random.categorical(logits / temperature, num_samples=1, seed=3)
print(sample.numpy())
```

The exact sampled token can vary with random-state and runtime details. Top-k sampling restricts candidates to the largest k scores; nucleus sampling chooses a probability-mass-based subset. These change the decoding policy, not the model's trained parameters. Evaluate factuality, diversity, repetition, and latency under the actual policy used in deployment.

A tiny randomly initialized language model produces no useful language merely because its sampling loop is correct. Separate algorithm mechanics from evidence of learned quality. Useful generation depends on data, capacity, training, and the relationship between the objective and the desired behavior.

## 17. Autoencoders learn through reconstruction

An autoencoder maps an input to a latent representation and reconstructs the input from that representation. The encoder compresses or transforms; the decoder rebuilds. A reconstruction loss compares the output to the original input.

```python
import tensorflow as tf
from tensorflow import keras

inputs = keras.Input(shape=(8,))
latent = keras.layers.Dense(3, activation="relu", name="latent")(inputs)
reconstruction = keras.layers.Dense(8)(latent)
autoencoder = keras.Model(inputs, reconstruction)
autoencoder.compile(optimizer="adam", loss="mse", jit_compile=False)
examples = tf.random.uniform([32, 8])
autoencoder.fit(examples, examples, epochs=2, batch_size=8, verbose=0)
print(autoencoder(examples[:2], training=False).shape)
```

The same array supplies inputs and targets, but the model is constrained by its bottleneck and architecture. Without a meaningful constraint, an autoencoder may simply learn an identity map. Reconstruction quality alone does not guarantee that the latent space supports useful semantic interpolation or downstream prediction.

For denoising, corrupt the input while retaining the clean target. Then the objective encourages recovery of stable structure. For anomaly detection, a reconstruction model may assign larger error to unfamiliar patterns, but it can also reconstruct some anomalies well. Validate against the actual anomaly distribution and a realistic operating threshold.

An ordinary autoencoder is not automatically a generative probability model. Sampling arbitrary latent vectors may land in regions the decoder never learned to use. A variational autoencoder adds a probabilistic latent structure and a regularized objective to make sampling more principled.

## 18. Variational, adversarial, and diffusion objectives

A variational autoencoder uses an encoder distribution \(q_\phi(z\mid x)\) and a decoder likelihood \(p_\theta(x\mid z)\). Its common training objective combines expected negative reconstruction log likelihood with a KL divergence toward a prior. The KL term discourages an arbitrary disconnected latent encoding and supports a sampling relationship with the prior.

For a diagonal Gaussian encoder, sample with \(z=\mu+\exp(\tfrac12\log\sigma^2)\epsilon\), where epsilon is standard normal. This reparameterization expresses randomness separately from differentiable parameters. The Gaussian-to-standard-normal KL is

\[
\frac12\sum_j\left(\mu_j^2+\sigma_j^2-1-\log\sigma_j^2\right).
\]

Reconstruction and KL reductions must use consistent scales. Summing pixels while averaging latent dimensions can change their relative influence dramatically. Derive the per-example terms before choosing a batch reduction.

A GAN trains a generator against a discriminator using competing objectives. The discriminator learns to distinguish real from generated samples, while the generator learns to produce samples that receive favorable discriminator scores. Alternating updates require careful control of which variable set receives each gradient. A single supervised `fit` call does not describe the full game unless a custom training step implements it.

A diffusion model learns to reverse a corruption process. A simplified denoising objective samples a time, adds a time-dependent amount of noise, and trains a network to estimate the noise or another equivalent target. Generation then uses a schedule of reverse updates. The time conditioning and noise schedule are integral parts of the model, not cosmetic metadata.

These families solve different modeling problems and have substantial specialized literatures. This course establishes the TensorFlow mechanisms and mathematical objectives needed to read and implement a small version; it does not claim that a few paragraphs reproduce production-scale generative training. Use the official worked examples in the source guide for expanded task-specific implementations.

## 19. Choose the simplest structure that supports the task

A dense network is a strong starting point for fixed numerical features. A convolutional network uses local spatial sharing. A recurrent network processes ordered state updates. Attention models flexible pairwise interactions. A pretrained model can offer useful representations when its domain and preprocessing match the target.

| Structure | Useful bias | Main cost or limitation |
| --- | --- | --- |
| Dense | General feature interactions | Ignores spatial or sequence structure |
| Convolution | Locality and shared filters | May need depth for distant interactions |
| Recurrence | Ordered state evolution | Sequential computation and memory limits |
| Full attention | Direct contextual interactions | Quadratic position-pair structure |
| Pretrained encoder | Reuse learned features | Domain and preprocessing dependence |

Architecture comparisons should hold data splits and evaluation contracts fixed. If one model sees more data or a different target definition, a score difference cannot be attributed only to the layer family. Measure latency, memory, and failure slices as well as accuracy.

The final chapter brings these models back to engineering: custom layers and loops, graph execution, profiling, distributed training, saving, and serving. Those mechanisms allow you to turn a correct experiment into a reproducible artifact with a documented input-output contract.

Further reading: [convolution layers](https://keras.io/api/layers/convolution_layers/), [recurrent layers](https://keras.io/api/layers/recurrent_layers/), [MultiHeadAttention](https://keras.io/api/layers/attention_layers/multi_head_attention/), [transfer learning](https://keras.io/guides/transfer_learning/), and [Keras examples](https://keras.io/examples/). The chapter's architecture derivations are independent explanations; the linked documentation specifies library contracts.

## Extended study — A variational example and careful architecture comparisons

### Reparameterization can be implemented directly

The following complete experiment is a small Gaussian variational autoencoder for eight-dimensional synthetic vectors. Its purpose is to connect the stated objective to code. It does not train a useful image generator or establish that a Gaussian likelihood matches a particular real dataset.

```python
import tensorflow as tf
from tensorflow import keras

keras.utils.set_random_seed(23)
encoder = keras.Sequential([
    keras.Input(shape=(8,)),
    keras.layers.Dense(16, activation="relu"),
    keras.layers.Dense(4),
])
decoder = keras.Sequential([
    keras.Input(shape=(2,)),
    keras.layers.Dense(16, activation="relu"),
    keras.layers.Dense(8),
])
optimizer = keras.optimizers.Adam(0.001)
examples = tf.random.normal([32, 8])

for step in range(20):
    with tf.GradientTape() as tape:
        parameters = encoder(examples, training=True)
        mean, log_variance = tf.split(parameters, 2, axis=-1)
        epsilon = tf.random.normal(tf.shape(mean))
        latent = mean + tf.exp(0.5 * log_variance) * epsilon
        reconstructed_mean = decoder(latent, training=True)
        # Unit-variance Gaussian negative log likelihood, ignoring constants.
        reconstruction = 0.5 * tf.reduce_sum(
            tf.square(examples - reconstructed_mean), axis=-1,
        )
        kl = 0.5 * tf.reduce_sum(
            tf.square(mean) + tf.exp(log_variance) - 1.0 - log_variance,
            axis=-1,
        )
        objective = tf.reduce_mean(reconstruction + kl)
    variables = encoder.trainable_variables + decoder.trainable_variables
    gradients = tape.gradient(objective, variables)
    optimizer.apply_gradients(zip(gradients, variables))
print("Objective:", float(objective.numpy()))
print("Generated means:", decoder(tf.random.normal([2, 2]), training=False).shape)
```

The encoder emits four numbers per example: two means and two log variances. Splitting the last axis gives the parameters of a diagonal two-dimensional Gaussian. Exponentiating half the log variance produces its standard deviation. The sampled epsilon introduces randomness without blocking derivatives with respect to the Gaussian parameters.

The reconstruction term sums feature contributions per example. The KL term sums latent-coordinate contributions per example. Only then does the code average across the batch. This mirrors a coherent per-example objective. Changing one sum to a mean changes the relative objective weight and should be treated as a modeling change.

The decoder output is a Gaussian mean under the stated likelihood. Producing one such mean is not the same as sampling the complete observation distribution. To sample under the unit-variance Gaussian likelihood, also add observation noise. For bounded image pixels, a different likelihood or parameterization may be more suitable.

A common failure is posterior collapse: the decoder learns to ignore the latent representation, and the encoder stays close to the prior. This can occur when the decoder can model the task without using the latent. Investigate reconstruction and KL components separately rather than looking only at total loss.

### A contrastive objective teaches another representation strategy

Supervised classification learns features useful for supplied labels. Contrastive learning instead encourages representations of related views to be similar relative to other examples. A positive pair might be two valid augmentations of the same image. The augmentation policy defines what variations should preserve identity.

Normalize embeddings before dot-product similarity when the chosen objective assumes cosine-style comparisons. A temperature controls the sharpness of the softmax over candidate matches. Negatives drawn from a batch can create accidental false negatives when two different examples represent the same semantic concept.

This objective uses ordinary TensorFlow operations and automatic differentiation; it does not require a separate gradient engine. The difficulty lies in defining positive relationships, batch construction, numerical stability, and evaluation of the learned representation. A low contrastive loss does not establish usefulness for every downstream task.

### Forecasting connects causal structure to evaluation

For a time series, construct windows using only information available before the forecast target. Fit scalers on the training interval. Split by time before creating overlapping windows or otherwise ensure no target-period information crosses boundaries. Randomly splitting heavily overlapping windows can make evaluation nearly duplicate training contexts.

Compare a sequence model against a last-value or seasonal baseline. Report error by forecast horizon because predicting one step ahead and predicting a month ahead have different difficulty. If a model consumes future known covariates, distinguish genuinely known calendar or scheduled information from measurements unavailable at prediction time.

### Architecture search needs controlled comparisons

Compare models under a clear resource budget. Equal epoch counts do not mean equal compute, because larger networks and different batches change step cost. Equal parameter counts do not mean equal latency, because operator shapes and hardware utilization differ. Measure the quantities that matter for the intended use.

Keep preprocessing, target encoding, split identities, and decision thresholds consistent unless those are the experimental variables. Record initialization seeds and repeat important comparisons when variation is material. A single tiny improvement can be noise rather than a reliable architectural advantage.

Optional application: train a dense baseline and a small convolutional model on the same image split. Compare their parameter counts, validation errors, and inference times before deciding whether spatial parameter sharing helped this particular dataset.
