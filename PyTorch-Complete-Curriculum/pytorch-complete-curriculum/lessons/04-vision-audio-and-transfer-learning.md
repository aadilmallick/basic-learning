# 4. Learning from images and signals: convolution, residuals, and transfer

[Previous](03-data-training-and-evaluation.md) · [Course index](../README.md) · [Next: sequences and transformers](05-sequences-attention-and-transformers.md)

## A different structure in the inputs

A table of unrelated measurements does not necessarily have meaningful neighboring columns. An image does: neighboring pixels often describe related parts of an object. A waveform also has local structure: nearby samples form patterns over time. A fully connected layer can process these inputs after flattening, but it ignores their geometry unless it learns that geometry from examples.

Convolution introduces an architectural assumption: a local pattern may be useful in several locations. Reusing one filter across locations reduces parameter count and gives a useful inductive bias. In this chapter we derive the operation, build a complete image classifier on generated data, explain residual networks and transfer learning, and connect spatial ideas to audio. The purpose is understanding the reusable mechanisms, not claiming that one toy dataset demonstrates real visual intelligence.

## 4.1 Pixels are measurements with an axis convention

A grayscale image assigns one intensity to each spatial position. A color image commonly has three channels representing red, green, and blue. An image batch in ordinary PyTorch convolution code has logical shape `[B, C, H, W]`. Images loaded by other libraries may arrive as `[H, W, C]`, so convert axes deliberately.

```python
import torch

height_width_channel = torch.arange(2 * 3 * 3).reshape(2, 3, 3)
channel_height_width = height_width_channel.permute(2, 0, 1)
batch = channel_height_width.unsqueeze(0).float()
print(batch.shape)
print(batch[0, :, 0, 0])
```

The batch shape is `[1, 3, 2, 3]`. The final print selects all channels of the upper-left pixel. Using `reshape` instead of `permute` could produce the same shape while assigning channel values to the wrong positions. The semantic axis mistake is more important than whether the code executes.

Byte-valued images typically use integers from zero through 255. A floating-point model usually expects a defined scale, often zero through one followed by channelwise normalization. Converting dtype alone does not necessarily rescale values. Make the scaling explicit or use a documented image transformation whose input contract matches your data.

Display functions often expect height-width-channel layout and values within a certain range. Undo normalization and rearrange axes for visualization rather than changing the model input merely to make a plot look correct. A display representation and a learning representation can legitimately differ.

## 4.2 Deriving one convolution output by hand

Imagine a small grayscale patch and a two-by-two filter. Multiply each patch value by the corresponding filter value and sum the products. Add a bias if the layer uses one. Slide the filter to another position and repeat. The same coefficients are used everywhere.

For a patch `[[1, 2], [3, 4]]` and filter `[[1, 0], [0, -1]]`, the output is `1 - 4 = -3`. This filter responds to a particular local contrast. A learned filter is not constrained to a human-designed edge pattern, but the arithmetic is identical.

```python
import torch
from torch.nn import functional as F

image = torch.tensor([[[[1.0, 2.0, 3.0],
                        [4.0, 5.0, 6.0],
                        [7.0, 8.0, 9.0]]]])
filter_weights = torch.tensor([[[[1.0, 0.0], [0.0, -1.0]]]])
output = F.conv2d(image, filter_weights)
print(output)
print(output.shape)
```

The output has shape `[1, 1, 2, 2]`, and each value is negative four. The first patch compares one with five. PyTorch's commonly named convolution operation uses the cross-correlation convention: it does not spatially reverse the kernel as a mathematical convolution definition may. Learned filters can adapt under either convention, but the distinction matters when matching a hand calculation.

The first two filter dimensions are output channels and input channels. For three input channels and eight learned filters of spatial size three by three, the weight shape is `[8, 3, 3, 3]`. Each output channel sums contributions over all three input channels within its local patch.

## 4.3 Stride, padding, and dilation control geometry

Stride determines how far the filter moves between output positions. Padding adds a boundary convention, often zeros outside the image. Dilation spaces kernel taps farther apart, increasing the spatial span without adding kernel coefficients. All three affect the output size and the information each output sees.

For one spatial axis with input length `I`, kernel size `K`, padding `P`, dilation `D`, and stride `S`, the output length is

\[
O=\left\lfloor\frac{I+2P-D(K-1)-1}{S}+1\right\rfloor.
\]

For input length eight, kernel three, padding one, dilation one, and stride two, the result is four. Calculate height and width separately. A formula is more dependable than guessing until the next fully connected layer accepts the tensor.

```python
import torch
from torch import nn

layer = nn.Conv2d(3, 8, kernel_size=3, stride=2, padding=1)
image_batch = torch.randn(4, 3, 8, 8)
print(layer(image_batch).shape)
```

The shape is `[4, 8, 4, 4]`. Padding preserves access to boundary locations but introduces assumptions about values beyond the image. Zero padding can make edge behavior different from interior behavior. Translation equivariance is therefore approximate near boundaries and can be affected by stride and other operations.

Dilation is useful when a wider context is needed without proportionally more coefficients. It can also create sparse sampling patterns that miss fine local structure. Strided convolutions and pooling reduce resolution, trading detailed localization for computation and larger effective context. The appropriate tradeoff differs between image classification and precise segmentation.

## 4.4 Parameter sharing and receptive fields

A dense layer mapping a flattened `32 × 32 × 3` image to one hundred hidden values uses over three hundred thousand weights. A convolution with sixteen three-by-three filters over three channels uses `16 × 3 × 3 × 3` weights, plus biases if enabled. Its output covers many locations using those shared coefficients.

This efficiency comes from a prior assumption, not a mathematical miracle. A useful edge detector may be useful in many parts of an image. If each spatial location has a completely different meaning, sharing may be less suitable. Architecture design is the act of choosing assumptions that fit the problem.

A receptive field is the region of the original input that can influence an output position. Stacking local layers expands it. Two stride-one three-by-three convolutions give an interior receptive field spanning five positions per axis, though the effective influence of positions can vary after learning. Downsampling expands receptive fields faster but reduces spatial precision.

Do not confuse receptive field with guaranteed understanding. Seeing the whole image in the dependency graph does not mean a network uses every region sensibly. Occlusion experiments, attribution tools, and carefully designed counterexamples can reveal which information drives its predictions, with their own limitations.

## 4.5 Pooling summarizes local or global information

Max pooling takes the largest value in a region. Average pooling takes its mean. Both reduce spatial resolution when their stride does so. Max pooling emphasizes the presence of a strong response; average pooling preserves an aggregate response. Neither is universally best.

Global average pooling averages each feature channel across its spatial axes. An activation tensor `[B, C, H, W]` becomes `[B, C]`. A final linear classifier then combines channel summaries. This avoids a large fully connected layer tied to one exact spatial resolution.

```python
import torch
from torch import nn

features = torch.randn(2, 8, 7, 9)
pooled = nn.AdaptiveAvgPool2d((1, 1))(features).flatten(1)
classifier = nn.Linear(8, 3)
print(pooled.shape, classifier(pooled).shape)
```

The shapes are `[2, 8]` and `[2, 3]`. Flattening from dimension one preserves the batch axis. Global averaging intentionally discards detailed spatial position, which is reasonable for some classification tasks and inappropriate when the output needs precise locations.

Pooling can improve tolerance to small translations, but a classification model is not automatically invariant to every geometric change. Rotations, scale shifts, and background changes can still cause failures. Use evaluation examples that reflect the transformations expected in practice.

## 4.6 A complete generated-image dataset

To study a CNN without downloads, generate small images containing vertical or horizontal bright bars. Randomize the bar position and add mild noise. The label describes orientation. This gives local reusable patterns and a clear target definition.

```python
import torch
from torch.utils.data import TensorDataset

def make_bars(count, seed):
    generator = torch.Generator().manual_seed(seed)
    labels = torch.randint(0, 2, (count,), generator=generator)
    images = 0.08 * torch.randn(count, 1, 16, 16, generator=generator)
    positions = torch.randint(2, 12, (count,), generator=generator)
    for index in range(count):
        position = int(positions[index])
        if int(labels[index]) == 0:
            images[index, 0, :, position:position + 2] += 1.0
        else:
            images[index, 0, position:position + 2, :] += 1.0
    return TensorDataset(images, labels)

examples = make_bars(10, seed=5)
print(examples[0][0].shape, examples[0][1].dtype)
```

The image shape is `[1, 16, 16]`, and labels are integer class IDs. The batch dimension appears only when a loader stacks items. The target depends on orientation, so a rotation by ninety degrees would change the label. This is why arbitrary rotation would be an invalid label-preserving augmentation for this task.

The dataset is deliberately simple. High accuracy here demonstrates that the implementation can detect the synthetic pattern. It does not establish robustness to real images, camera artifacts, occlusion, or semantic categories. Synthetic examples are useful because they isolate mechanisms; their limitations should remain explicit.

## 4.7 A CNN whose shapes can be followed

The next model uses two convolutional stages and global averaging. Read each layer as a transformation of an axis contract, rather than as a collection of familiar names.

```python
import torch
from torch import nn

class BarClassifier(nn.Module):
    def __init__(self):
        super().__init__()
        self.features = nn.Sequential(
            nn.Conv2d(1, 8, kernel_size=3, padding=1),
            nn.ReLU(),
            nn.MaxPool2d(2),
            nn.Conv2d(8, 16, kernel_size=3, padding=1),
            nn.ReLU(),
            nn.AdaptiveAvgPool2d((1, 1)),
        )
        self.classifier = nn.Linear(16, 2)

    def forward(self, images):
        representation = self.features(images).flatten(1)
        return self.classifier(representation)

model = BarClassifier()
print(model(torch.randn(4, 1, 16, 16)).shape)
print(sum(parameter.numel() for parameter in model.parameters()))
```

The first convolution maps one input channel to eight and retains sixteen-by-sixteen spatial dimensions. Pooling reduces them to eight-by-eight. The second convolution creates sixteen channels while preserving that reduced spatial size. Global pooling creates sixteen features per example. The final output has two logits, so its shape is `[4, 2]`.

No softmax appears in forward because multiclass cross entropy consumes logits. The model's parameter count is small enough to inspect. Increasing channel width adds capacity and cost, but does not fix a dataset with an invalid split or an augmentation that changes the label.

## 4.8 Training the image model

The following standalone program includes the dataset and model definitions compactly so it can be copied without relying on notebook state. Its training structure is the same as Chapter 3.

```python
import torch
from torch import nn
from torch.utils.data import TensorDataset, DataLoader

def make_bars(count, seed):
    generator = torch.Generator().manual_seed(seed)
    labels = torch.randint(0, 2, (count,), generator=generator)
    images = 0.08 * torch.randn(count, 1, 16, 16, generator=generator)
    positions = torch.randint(2, 12, (count,), generator=generator)
    for index in range(count):
        position = int(positions[index])
        if int(labels[index]) == 0:
            images[index, 0, :, position:position + 2] += 1.0
        else:
            images[index, 0, position:position + 2, :] += 1.0
    return TensorDataset(images, labels)

class BarClassifier(nn.Module):
    def __init__(self):
        super().__init__()
        self.features = nn.Sequential(
            nn.Conv2d(1, 8, 3, padding=1), nn.ReLU(), nn.MaxPool2d(2),
            nn.Conv2d(8, 16, 3, padding=1), nn.ReLU(),
            nn.AdaptiveAvgPool2d(1),
        )
        self.classifier = nn.Linear(16, 2)
    def forward(self, images):
        return self.classifier(self.features(images).flatten(1))

@torch.no_grad()
def accuracy(model, loader, device):
    model.eval()
    correct, count = 0, 0
    for images, labels in loader:
        images, labels = images.to(device), labels.to(device)
        correct += (model(images).argmax(-1) == labels).sum().item()
        count += len(labels)
    return correct / count

def main():
    torch.manual_seed(41)
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    training = DataLoader(make_bars(512, 1), batch_size=32, shuffle=True)
    validation = DataLoader(make_bars(128, 2), batch_size=64)
    model = BarClassifier().to(device)
    optimizer = torch.optim.Adam(model.parameters(), lr=0.01)
    for epoch in range(8):
        model.train()
        for images, labels in training:
            images, labels = images.to(device), labels.to(device)
            optimizer.zero_grad(set_to_none=True)
            logits = model(images)
            loss = nn.functional.cross_entropy(logits, labels)
            loss.backward()
            optimizer.step()
        print(epoch, accuracy(model, validation, device))

if __name__ == '__main__':
    main()
```

Expect validation accuracy to improve on this easy problem, but treat the printed output as an experiment rather than a promised exact trajectory. The seeds separate generated training and validation examples. In a real image task, split by the independent source unit, such as patient, scene, or original video, before producing crops.

## 4.9 Normalization inside a network

Input standardization transforms measurements before learned computation. Batch normalization and layer normalization transform intermediate activations. Their purpose and axes differ. Batch normalization for image features uses statistics over batch and spatial positions separately for each channel under its ordinary training behavior. Layer normalization uses specified trailing feature axes within each example.

Batch normalization maintains running statistics for evaluation. A small or unusual training batch can give noisy estimates. Freezing weights alone does not stop running statistics from changing if the module remains in training mode. This matters greatly in transfer learning.

Layer normalization does not use the same batch-dependent running-statistic mechanism. It is common in sequence models because it normalizes features at each token position. The next chapter uses it in residual transformer blocks. Do not exchange normalization types solely because they both contain the word normalization; they encode different dependence structures.

Normalization can improve optimization, but it does not excuse poorly scaled raw inputs or invalid preprocessing. It can also alter information the task needs. If absolute signal amplitude predicts a target, normalizing every example independently may remove that signal. Understand what variation the transform suppresses.

## 4.10 Residual connections make depth easier to optimize

A residual block outputs `x + F(x)`, where `F` is a learned transformation. If the identity mapping is already useful, the block can learn a small correction rather than reconstructing the whole signal. The derivative also has an identity contribution, helping information and gradients pass through deep stacks.

```python
import torch
from torch import nn

class ResidualBlock(nn.Module):
    def __init__(self, channels):
        super().__init__()
        self.branch = nn.Sequential(
            nn.Conv2d(channels, channels, 3, padding=1),
            nn.ReLU(),
            nn.Conv2d(channels, channels, 3, padding=1),
        )
        self.activation = nn.ReLU()
    def forward(self, features):
        return self.activation(features + self.branch(features))

block = ResidualBlock(8)
print(block(torch.randn(2, 8, 16, 16)).shape)
```

The addition requires compatible shapes. If a block changes channel count or spatial resolution, use a projection path, often a one-by-one convolution with suitable stride, so the skip branch matches. An accidental broadcast at a residual addition can create a legal but unintended network, so inspect both operands.

Residual connections do not guarantee that arbitrary depth trains well. Initialization, normalization, optimizer settings, and data still matter. The useful intuition is that the architecture offers an easy path for carrying existing features while learning refinements. This same idea reappears in transformers and diffusion networks.

## 4.11 Transfer learning reuses a learned representation

Training a large vision model from random initialization can require substantial labeled data. A pretrained model may already encode useful visual features. Transfer learning adapts that representation to a new task. This is a hypothesis about relatedness between the pretraining distribution and your task, not a guarantee.

Two common stages are feature extraction and fine-tuning. Feature extraction freezes the backbone and trains a new output head. Fine-tuning updates some or all backbone parameters, often with a smaller learning rate. Begin with the frozen baseline because it is cheaper and provides evidence about representation usefulness.

The following example requires a compatible torchvision installation and a download of pretrained weights if they are not cached. It constructs an inference-ready architecture but does not claim to train it on an unspecified dataset.

```python
import torch
from torch import nn
from torchvision.models import resnet18, ResNet18_Weights

weights = ResNet18_Weights.DEFAULT
model = resnet18(weights=weights)
for parameter in model.parameters():
    parameter.requires_grad_(False)
model.fc = nn.Linear(model.fc.in_features, 3)
model.eval()
model.fc.train()
optimizer = torch.optim.AdamW(model.fc.parameters(), lr=1e-3)
preprocess = weights.transforms()
print(model.fc)
```

The weight enum supplies the associated preprocessing transform. That pairing matters: the pretrained network expects a particular scale and normalization. Replacing the head creates new trainable parameters after freezing the old ones. Constructing the optimizer afterward ensures it references the actual replacement head.

When training only this head, keep the backbone's batch normalization layers in evaluation mode if you intend to preserve their running statistics. Calling `model.train()` later recursively changes them back, so reapply the intended mode policy. Freezing `requires_grad` and freezing behavioral state are separate actions.

## 4.12 Fine-tuning without destroying the baseline

After training a head, unfreeze selected backbone layers if validation suggests the representation needs adaptation. Use parameter groups to give the pretrained layers a smaller learning rate than the new head. This reflects a reasonable desire to preserve useful features while allowing correction.

A careful procedure stores the frozen-baseline checkpoint, changes the trainable parameter policy explicitly, rebuilds or adjusts the optimizer deliberately, and compares validation performance under the same split. If the optimizer is rebuilt, its moment history changes. That is acceptable when intentional, but it should not be mistaken for a perfectly continuous training run.

Catastrophic forgetting describes the loss of previously useful behavior during adaptation. A high learning rate, small dataset, or large domain shift can contribute. Smaller updates, partial freezing, and representative validation can help, but none removes the need to evaluate the new task and any old capabilities you still require.

Pretraining can also carry unwanted shortcuts and biases. A model pretrained on ordinary photographs may behave poorly on medical images or industrial textures. Compare against a simpler baseline and inspect error categories. A well-known architecture name is not evidence that its learned features suit your population.

## 4.13 Data augmentation expresses a task assumption

A horizontal flip often preserves a natural-image category, but not always. A crop may remove the only relevant object. Color changes may destroy a diagnostic cue. The label must remain valid after the transformation, and the transformed examples should resemble plausible deployment variation.

Apply random augmentation to training examples. Validation usually uses a deterministic transform associated with the task and pretrained weights. If test-time augmentation is used, describe the aggregation rule and account for its cost. It is a separate inference method, not the same as accidentally leaving random training transforms active.

For segmentation, geometric transformations must be applied consistently to image and label mask. Interpolation also matters: class-index masks should not use interpolation that invents fractional class IDs. Bounding boxes need coordinate updates after resizing or cropping. These are examples of target-preserving transformations requiring more than changing the input tensor.

Augmentation strength should be evaluated. Too little may allow reliance on narrow visual details. Too much may make the training task unrealistic or impossible. Inspect transformed examples visually before running a long experiment, and keep the original source split intact so augmented versions do not leak across partitions.

## 4.14 From classification to segmentation and detection

Classification assigns a label or distribution to an entire image. Segmentation assigns labels to spatial positions. Detection predicts object locations and categories, often with a variable number of objects. The backbone can be similar, but output contracts and objectives differ substantially.

For semantic segmentation with `C` classes, logits often have shape `[B, C, H, W]` and class-index targets `[B, H, W]`. Cross entropy combines class competition independently at each spatial position under that contract. Ignore labels can exclude unannotated pixels, but the reduction must reflect which pixels are valid.

An encoder-decoder segmentation model reduces resolution to learn context and then upsamples to recover spatial predictions. Skip connections can pass fine details from earlier stages. Upsampling a coarse representation does not magically restore information already discarded; the architecture and supervision must support localization.

Detection requires matching predicted candidates with target objects and handling background, localization losses, and postprocessing. This course establishes the PyTorch foundations needed to read such systems, but a full treatment of every detection architecture would be its own course. Use the official domain tutorials for the specialized matching and evaluation protocols rather than improvising from a classifier template.

## 4.15 Audio begins with sampling

A waveform is a sequence of amplitude measurements taken at a sample rate. A tensor with sixteen thousand samples represents one second at sixteen kilohertz, but half a second at thirty-two kilohertz. Shape alone does not encode time duration. Preserve sample rate as part of the data contract.

A batch of mono waveforms can have shape `[B, 1, T]`, matching `Conv1d`'s channel convention. A one-dimensional filter detects local patterns over time. Its parameters are shared across positions just as a spatial filter is shared across image locations.

```python
import torch
from torch import nn

sample_rate = 16000
time = torch.arange(sample_rate, dtype=torch.float32) / sample_rate
waveform = torch.sin(2 * torch.pi * 440 * time)
batch = waveform.reshape(1, 1, -1)
features = nn.Conv1d(1, 8, kernel_size=9, stride=4, padding=4)(batch)
print(features.shape)
```

This creates a one-second pure tone at 440 hertz and applies a learned temporal filter bank with random initial weights. It does not recognize pitch yet; learning would require data and an objective. The example isolates how time samples become a convolutional input.

Resampling requires a signal-processing operation, not merely dropping elements or changing a metadata number. Frequencies above the new sampling limit must be handled appropriately to avoid aliasing. Domain libraries provide resampling implementations, but you should understand why the operation changes actual samples rather than just a label.

## 4.16 Spectrograms connect signals to image-like models

A Fourier transform decomposes a signal into frequency components. A short-time Fourier transform applies that analysis to overlapping windows, retaining how frequency content changes over time. The result has frequency and frame axes. Squared magnitudes form a power spectrogram.

```python
import torch

sample_rate = 16000
time = torch.arange(sample_rate, dtype=torch.float32) / sample_rate
waveform = torch.sin(2 * torch.pi * 440 * time)
window = torch.hann_window(400)
complex_spectrum = torch.stft(waveform, n_fft=400, hop_length=160,
                              win_length=400, window=window,
                              return_complex=True)
power = complex_spectrum.abs().square()
log_power = power.clamp_min(1e-8).log()
print(log_power.shape)
```

The window length is twenty-five milliseconds, and the hop is ten milliseconds. A longer window improves frequency resolution while reducing temporal localization. The log compresses dynamic range; clamping avoids the logarithm of zero. These choices encode tradeoffs in the representation, not arbitrary image formatting.

A spectrogram can be processed by a two-dimensional CNN, but its axes have different meanings. Shifting time may preserve an audio event's identity; shifting frequency may change pitch and meaning. Augmentations suitable for photographs should not be transferred mechanically. Mel features further aggregate frequencies on a perceptually motivated scale, often useful for speech and audio tasks.

Audio decoding and domain-library APIs change over releases, so this chapter's complete signal examples use generated tensors and core `torch.stft`. For real files, consult the currently compatible audio stack and verify sample-rate, channel, and decoding behavior before modeling.

## 4.17 Debugging a visual model systematically

Start by displaying actual training inputs after all transformations. Confirm channels, orientation, intensity range, and labels. Print the distribution of class IDs and inspect several examples from each class. A CNN cannot repair a reversed label mapping or an image tensor whose channels were accidentally flattened into spatial positions.

Next, overfit a tiny fixed batch. If that fails, inspect optimizer references, loss contract, gradients, and normalization modes. If it succeeds but validation fails, investigate split quality, domain mismatch, augmentation, and capacity. This is the same diagnostic separation used for tabular data, applied to a new input geometry.

For unexpectedly high accuracy, inspect whether backgrounds, filenames, borders, or acquisition devices correlate with labels. A model may learn these shortcuts because they reduce the objective. Counterexample datasets that break the shortcut can expose the reliance. Attribution maps can suggest hypotheses, but they are not a proof of causal reasoning.

Check behavior at different resolutions and batch sizes. Adaptive pooling may allow multiple spatial sizes, but a model trained at one resolution can still generalize poorly at another. Compatibility of shapes and stability of performance are distinct properties.

## 4.18 Optional application: a controlled robustness study

Train the bar classifier, then generate a validation set with stronger noise while keeping the orientation rule unchanged. Compare accuracy at several noise levels. Next, move bars closer to boundaries. These experiments ask specific questions about robustness and boundary behavior.

Now introduce a ninety-degree rotation and update the label accordingly. Compare that with rotating without changing the label, which creates a corrupted dataset for this task. The difference makes the meaning of label-preserving augmentation concrete. An augmentation pipeline should be judged by the relationship between transformed input and target, not merely by visual variety.

For transfer learning, compare a frozen backbone with partial fine-tuning on one real dataset you are permitted to use. Keep the split and evaluation transform fixed. Record training time, validation performance, and error categories. A slower model that improves only an irrelevant metric may not be a better engineering choice.

## 4.19 Tracking receptive field and sampling distance

A useful way to calculate a stack's geometry is to track two quantities: receptive-field width and the distance between adjacent output centers measured in original input pixels. Start with receptive field one and distance one. A layer with effective kernel width `D × (K - 1) + 1` expands the receptive field by its additional span multiplied by the previous distance. Its stride multiplies the distance.

For a three-wide stride-one convolution, the receptive field becomes three and distance remains one. A two-wide stride-two pooling layer expands the field to four and distance to two. Another three-wide stride-one convolution expands the field by four, producing a receptive field of eight. This calculation explains how a small stack can cover increasingly broad regions without any one large filter.

The theoretical field includes positions that could influence the output. Learned weights and nonlinearities determine how strongly they actually influence it. Boundary padding further changes which positions correspond to real measurements. Use the geometric calculation to understand possible information flow, then use experiments to investigate actual learned dependence.

This distinction is especially useful in time series. A causal convolution must avoid future samples, and its receptive field determines how much history is available. Symmetric padding that is harmless for an offline image classifier can leak future information in a forecasting model. Geometry becomes part of the validity of the learning task.

## 4.20 Grouped and depthwise convolution

Ordinary convolution mixes all input channels into every output channel. Grouped convolution divides channels into groups and restricts mixing within each group. Depthwise convolution is the special pattern where each input channel is filtered separately, usually followed by a pointwise one-by-one convolution that mixes channels.

The arithmetic can be much cheaper. For input channels `C`, output channels `O`, and spatial kernel width `K`, ordinary convolution uses approximately `C × O × K²` weights. A depthwise stage followed by a pointwise stage uses approximately `C × K² + C × O` weights under the simple one-filter-per-channel arrangement. The reduction comes from separating spatial filtering from channel mixing.

```python
import torch
from torch import nn

separable = nn.Sequential(
    nn.Conv2d(8, 8, kernel_size=3, padding=1, groups=8),
    nn.ReLU(),
    nn.Conv2d(8, 16, kernel_size=1),
)
print(separable(torch.randn(2, 8, 12, 12)).shape)
```

The output is `[2, 16, 12, 12]`. Fewer theoretical operations do not guarantee lower observed latency on every device. Kernel implementation, memory access, batch size, and hardware utilization matter. Chapter 7 teaches how to measure the actual workload rather than ranking architectures solely by parameter count or operation estimates.

## 4.21 Segmentation metrics reveal spatial failure

Pixel accuracy can be high when most pixels are background. A model that predicts only background may then appear useful while missing every small object. Intersection over union, or IoU, compares the overlap between predicted and target regions with their union. Dice overlap uses twice the intersection divided by total predicted and target region sizes.

For a binary object mask, suppose the prediction contains twenty pixels, the target contains thirty, and fifteen overlap. IoU is `15 / (20 + 30 - 15)`, or fifteen over thirty-five. Dice is thirty over fifty. These metrics answer a spatial overlap question that ordinary image-level accuracy cannot.

Empty regions require an explicit convention. If both prediction and target are empty, the union is zero; implementations differ in how they report that case. Averaging over images, classes, or all pixels also changes the result. Document aggregation and ignore-label policy when comparing systems.

For small structures, a few misplaced pixels can dominate overlap. Boundary distances or task-specific measurements may therefore be needed alongside IoU. The broader principle is the same as Chapter 3: select measurements that reflect the practical error, then implement their denominators and masks carefully.

## 4.22 Reading a pretrained architecture as a system

When opening an unfamiliar vision model, first identify input channels, spatial downsampling stages, channel widths, normalization layers, skip connections, and the final output head. Trace one small batch through these stages with hooks or temporary shape prints. Avoid printing entire activation tensors; their shapes and summary statistics are usually more informative.

Inspect the parameter policy separately. Which layers are trainable? Which maintain running state? Which preprocessing transform is associated with the weights? What class ordering did the original head use? These questions prevent a familiar architecture name from hiding important integration details.

A model with many parameters may still be practical if most are frozen and inference latency is acceptable. A smaller model can still be slow if its operations map poorly to the target hardware. Memory use also includes activations and optimizer state, not merely stored weights. Architecture understanding should therefore connect mathematical structure, learning behavior, and measured execution.

Finally, preserve the task boundary. A pretrained feature extractor is a starting representation. Your training data, adapted head, preprocessing, threshold policy, and evaluation procedure together define the actual application. The next chapter reuses these same principles for text, where tokens replace pixels and attention provides a different way to exchange information.

### A note on visual explanations

A filter visualization can make early learned patterns tangible, but later channels are not necessarily clean object detectors. Several channels can jointly encode a property, and one channel can participate in several useful distinctions. Avoid assigning a confident semantic name to every activation simply because one example looks suggestive.

Likewise, a highlighted region in a saliency map indicates sensitivity under a particular attribution procedure. Different procedures answer different questions, and preprocessing or saturation can affect the result. Use these tools to generate testable hypotheses. For example, if a map emphasizes image borders, create examples with border variation while preserving the object and evaluate the predictions.

This experimental approach is more informative than treating a visualization as a complete explanation. It connects a proposed interpretation to an intervention and an observed outcome. The same caution applies to attention maps in the next chapter: a visible weight distribution is an internal calculation, and understanding its relationship to a final decision requires additional reasoning and evidence.

## Sources

Consult [Conv2d](https://docs.pytorch.org/docs/2.15/generated/torch.nn.Conv2d.html) for operator geometry, [ResNet-18 weights and transforms](https://docs.pytorch.org/vision/stable/models/generated/torchvision.models.resnet18.html) for the pretrained interface, and the official [tutorial collection](https://docs.pytorch.org/tutorials/beginner/basics/intro.html) for domain-specific continuations. Accessed November 12, 2026. The arithmetic examples, synthetic dataset, and teaching explanations are original.
