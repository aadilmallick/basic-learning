# 3. Building a reliable experiment: data, training, evaluation, and checkpoints

[Previous](02-gradients-and-neural-networks.md) · [Course index](../README.md) · [Next: vision and audio](04-vision-audio-and-transfer-learning.md)

## Why a correct backward pass is only the beginning

A model can calculate every gradient correctly and still produce a misleading result. Examples may leak across splits. A validation loop may leave dropout active. A reported average may give the final short batch too much weight. A checkpoint may omit the normalization statistics needed to interpret its inputs. These are not peripheral production concerns; they determine what your experiment means.

This chapter develops one dependable training pattern from data contracts to a saved inference artifact. It assumes the tensor and gradient ideas from Chapters 1 and 2. We will use synthetic regression to keep the complete program independent of downloads, then discuss how the same structure applies to classification and real datasets. Synthetic success demonstrates the pipeline, not performance on a real application.

## 3.1 Define the unit of observation before splitting

A row is not always an independent example. Several rows may belong to the same person, building, customer, video, or recording session. If nearly identical observations from one entity appear in training and validation, the validation result may measure recognition of familiar entities rather than generalization to new ones.

Begin by stating what the deployed model will encounter. Will it predict future observations from known buildings or observations from entirely new buildings? Those are different tasks and may require different splits. For forecasting, a random split can reveal future information through patterns that would not be available at prediction time. A chronological split is often more faithful.

Training data determines fitted parameters and fitted preprocessing. Validation data supports model selection and hyperparameter choices. Test data provides a final assessment after those choices are settled. Repeatedly trying configurations until the test score improves turns the test set into another validation set, even if no gradient ever uses it.

The precise fractions depend on dataset size and task. More important than a familiar ratio is preserving the intended separation. Record identifiers and split membership so another run can reproduce the same partition. If you deduplicate, group, or filter records, document the order of those operations relative to splitting.

## 3.2 A dataset describes individual examples

A map-style dataset provides length and indexing. `__len__` tells the loader how many examples exist. `__getitem__` returns one example for a requested index. The dataset should give each field a clear meaning, type, and shape. For our simple task, an item is a feature vector and a scalar target.

```python
import torch
from torch.utils.data import Dataset

class RegressionDataset(Dataset):
    def __init__(self, features, targets):
        if features.ndim != 2 or targets.ndim != 1:
            raise ValueError('Expected features [N, F] and targets [N]')
        if len(features) != len(targets):
            raise ValueError('Example counts differ')
        self.features = features.to(torch.float32)
        self.targets = targets.to(torch.float32)

    def __len__(self):
        return len(self.targets)

    def __getitem__(self, index):
        return self.features[index], self.targets[index]

features = torch.tensor([[1.0, 2.0], [3.0, 4.0]])
targets = torch.tensor([5.0, 6.0])
dataset = RegressionDataset(features, targets)
print(len(dataset), dataset[0])
```

The stored tensors remain on CPU here. This keeps data access compatible with ordinary loader workers and avoids making every worker manage GPU state. The main training process moves each completed batch to its compute device. For small datasets, loading everything onto a device can be a deliberate alternative, but it should not be mixed accidentally with a multiprocessing loader design.

Real datasets often load an image or parse a record on demand instead of storing every value in memory. The same interface applies. Validate paths and target mappings before a long training run. If one corrupt file causes failures only in a late epoch, the training system should identify that file rather than silently returning a different label or dropping observations without a record.

## 3.3 A data loader turns items into batches

A `DataLoader` coordinates sampling, batching, and optional worker processes. By default, compatible tensor items are stacked along a new batch axis. If every feature vector has shape `[F]`, a batch has shape `[B, F]`. Scalar targets become `[B]`.

```python
import torch
from torch.utils.data import TensorDataset, DataLoader

features = torch.arange(20.0).reshape(10, 2)
targets = torch.arange(10.0)
dataset = TensorDataset(features, targets)
loader = DataLoader(dataset, batch_size=4, shuffle=False, num_workers=0)
for batch_features, batch_targets in loader:
    print(batch_features.shape, batch_targets.shape)
```

The batch sizes are four, four, and two. That last batch is important for metric aggregation and code that assumes a fixed batch size. Use runtime batch shapes instead of scattering a configured constant through reshapes. `drop_last=True` intentionally discards a short final batch; it is useful in some training settings but usually inappropriate for ordinary evaluation.

Shuffle training examples when the task permits random sampling. This reduces order artifacts and changes which examples share batches. Evaluation usually uses deterministic ordering without random augmentation. Shuffling validation does not ordinarily alter an order-independent metric, but keeping stable order makes error analysis easier.

Start with `num_workers=0` while debugging. It keeps exceptions in the main process and avoids multiprocessing surprises. On Windows and spawn-based environments, put script entry code inside `if __name__ == '__main__':`. Once correctness is established, benchmark worker counts. More workers can increase contention or memory use instead of improving throughput.

## 3.4 Transformations can be fixed, fitted, or random

A fixed transformation follows a predetermined rule, such as dividing byte-valued image pixels by 255. A fitted transformation estimates state from training examples, such as feature means. A random transformation samples a perturbation, such as a permitted image flip. These distinctions determine where each transformation belongs.

Fitted state must be estimated using training data alone. Validation and inference reuse it. Random training transformations should preserve the target meaning: flipping a traffic sign or changing a word can change its label in some tasks. Augmentation is an assertion about valid invariances, not free additional information.

For standardized regression, calculate statistics from the training split and clamp tiny scales. Preserve feature names and ordering alongside them. Missing-value handling also has fitted state if replacement values come from data. An imputation mean fitted on all observations before splitting leaks evaluation information even if the neural network itself only sees training rows.

A convenient module can store statistics as buffers:

```python
import torch
from torch import nn

class Standardize(nn.Module):
    def __init__(self, mean, scale):
        super().__init__()
        self.register_buffer('mean', mean.clone())
        self.register_buffer('scale', scale.clamp_min(1e-6).clone())

    def forward(self, features):
        return (features - self.mean) / self.scale

training = torch.tensor([[1.0, 10.0], [3.0, 20.0], [5.0, 30.0]])
transform = Standardize(training.mean(0), training.std(0, correction=0))
print(transform(training).mean(0))
print(list(transform.state_dict()))
```

Buffers move with the module and appear in its state dictionary, but are not trainable parameters by default. This makes preprocessing part of the saved computation without pretending that its statistics should receive gradient updates. The distinction is useful for normalization constants, positional encodings, and other persistent model state.

## 3.5 Write the training step with explicit responsibilities

A training step receives a batch, computes its objective, backpropagates, and updates parameters. Keep device movement and output contracts visible. A scalar objective should be finite. Predictions and targets should have the intended shapes before the loss function is called.

The following function is an intentional reusable fragment. It expects a model returning `[B, 1]`, which it converts to `[B]`. The evaluation helper below uses the same contract. The complete program later in this chapter instead uses a pipeline that already returns `[B]` and handles that output directly.

```python
def train_epoch(model, loader, optimizer, device):
    import torch
    model.train()
    total_squared_error = 0.0
    total_examples = 0
    for features, targets in loader:
        features = features.to(device)
        targets = targets.to(device)
        optimizer.zero_grad(set_to_none=True)
        predictions = model(features).squeeze(-1)
        if predictions.shape != targets.shape:
            raise ValueError('Prediction/target shape mismatch')
        loss = (predictions - targets).square().mean()
        if not torch.isfinite(loss):
            raise FloatingPointError('Nonfinite loss')
        loss.backward()
        optimizer.step()
        total_squared_error += loss.detach().item() * len(targets)
        total_examples += len(targets)
    if total_examples == 0:
        raise ValueError('Empty training loader')
    return total_squared_error / total_examples
```

Multiplying each batch mean by its example count reconstructs that batch's sum. Dividing the accumulated sum by total examples produces an example-weighted epoch mean. Averaging batch means directly would overrepresent a short final batch. If each example contains a variable number of valid tokens, the appropriate denominator may be valid tokens instead, which Chapter 5 handles explicitly.

The detached scalar is for logging. It does not keep the computation graph alive. Appending raw loss tensors to a Python list across batches can retain their graphs and cause apparent memory leaks. Store detached values or Python numbers unless you intentionally need differentiable history.

## 3.6 Evaluation measures a fixed model

Validation should not update parameters. It should also use the model behavior intended for evaluation. Enter evaluation mode and disable ordinary gradient recording. The two controls are independent, as Chapter 2 explained.

```python
import torch

@torch.no_grad()
def evaluate_regression(model, loader, device):
    model.eval()
    squared_sum = 0.0
    absolute_sum = 0.0
    count = 0
    for features, targets in loader:
        features, targets = features.to(device), targets.to(device)
        predictions = model(features).squeeze(-1)
        if predictions.shape != targets.shape:
            raise ValueError('Prediction/target shape mismatch')
        residual = predictions - targets
        squared_sum += residual.square().sum().item()
        absolute_sum += residual.abs().sum().item()
        count += targets.numel()
    if count == 0:
        raise ValueError('Empty evaluation loader')
    return {'mse': squared_sum / count, 'mae': absolute_sum / count}
```

Mean absolute error is in the target's original units. Root mean squared error, the square root of MSE, is also in those units but emphasizes large errors more strongly. Report the metric that matches the decision problem. A single average can conceal a small subgroup with very poor performance, so examine residuals by relevant categories and input ranges.

A training epoch's logged loss combines predictions from a changing model. A validation metric usually evaluates one fixed end-of-epoch model. Their difference therefore reflects more than generalization alone. Training augmentation and dropout can also make the training task harder. Interpret curves with awareness of exactly how each quantity was measured.

## 3.7 Classification metrics encode different priorities

Accuracy is the fraction of correct class decisions. For an imbalanced dataset, it can be misleading. A classifier that always predicts the common class may achieve high accuracy while failing on every important rare case. A confusion matrix counts true and predicted class combinations and makes that failure visible.

For binary decisions, precision is true positives divided by predicted positives. Recall is true positives divided by actual positives. A threshold trades one against the other. F1 combines precision and recall through a harmonic mean when both matter, but it still omits true negatives and does not express every cost structure.

```python
import torch

targets = torch.tensor([0, 0, 1, 1, 1])
probabilities = torch.tensor([0.1, 0.8, 0.7, 0.4, 0.9])
predictions = (probabilities >= 0.5).long()
confusion = torch.bincount(targets * 2 + predictions, minlength=4).reshape(2, 2)
true_positive = confusion[1, 1].item()
false_positive = confusion[0, 1].item()
false_negative = confusion[1, 0].item()
precision = true_positive / max(true_positive + false_positive, 1)
recall = true_positive / max(true_positive + false_negative, 1)
print(confusion)
print(precision, recall)
```

The matrix rows are true classes and columns predicted classes. Label that convention whenever presenting it. Here precision and recall are both two thirds. Handling a zero denominator requires a declared convention; returning zero is a possible reporting choice, but the absence of positive predictions should also be visible.

Area-under-curve measures summarize rankings across thresholds. They do not choose an operational threshold for you. Select thresholds using validation data and task costs, then evaluate the chosen decision rule on held-out data. Changing a threshold after looking at test errors is another form of test-driven model selection.

## 3.8 Probability quality and calibration

A probability estimates uncertainty under a model and data distribution. Calibration asks whether events assigned probability around a given value occur at approximately that frequency. A model can rank cases well and still be overconfident. Accuracy cannot diagnose this because it discards probability magnitudes after thresholding.

A reliability diagram groups predictions into bins and compares mean confidence with empirical frequency. Binning choices affect the estimate, and small bins are noisy. The Brier score averages squared probability errors for binary outcomes and provides another perspective. Negative log-likelihood strongly penalizes confident incorrect predictions.

Temperature scaling divides logits by a positive fitted scalar before softmax. Fit that scalar on a held-out calibration subset, preserving a final test set. It changes confidence without changing the highest-logit class for positive temperatures. It does not repair missing classes, severe distribution shift, or a model that learned irrelevant signals.

Uncertainty should also influence product behavior. Some applications can abstain, request additional information, or route low-confidence cases for review. Such behavior requires a validation procedure that measures the resulting coverage and error tradeoff. A confidence score alone is not a guarantee that a decision is safe or correct.

## 3.9 Reproducibility is a collection of controls

Set seeds for random sources you actually use. Python, NumPy, and PyTorch have distinct generators. A data loader may have its own generator and worker-specific randomness. Recording only one seed does not document the whole experiment.

```python
import random
import torch

seed = 23
random.seed(seed)
torch.manual_seed(seed)
loader_generator = torch.Generator().manual_seed(seed)
print(torch.rand(3, generator=loader_generator))
```

If NumPy generates data, seed its generator too. Strict deterministic algorithm settings can help isolate changes, but may reduce speed or reject operations that lack a deterministic implementation. Cross-platform and cross-release bitwise identity is not generally guaranteed. Record versions, hardware, dataset revision, split identifiers, configuration, and code revision instead of assuming that a seed is a complete reproduction recipe.

For comparisons, repeated runs can distinguish a real improvement from initialization noise. Report an average and variation when the question warrants it. A tiny improvement on one seed should not automatically justify a more complex architecture. The stronger the claimed conclusion, the more carefully the experiment should control alternative explanations.

## 3.10 Regularization changes the effective learning problem

Overfitting occurs when training performance improves without corresponding held-out improvement. A more flexible model can fit noise or idiosyncrasies of the training sample. Regularization constrains or biases the solution to improve performance on the intended distribution.

Weight decay discourages large parameter magnitudes through an update mechanism. Dropout perturbs hidden activations during training. Data augmentation broadens the training distribution using transformations assumed to preserve labels. Early stopping selects a training duration based on validation behavior. These mechanisms act differently and should not be treated as interchangeable switches.

Underfitting has a different signature: both training and validation performance are poor. Increasing regularization may make it worse. Inspect whether the model can fit a tiny clean subset, whether the objective matches target semantics, and whether optimization is making progress. More epochs are useful only if the model still improves under a valid setup.

A good baseline reduces ambiguity. Compare the neural network with a constant predictor, a simple linear model, or another task-appropriate baseline. If a sophisticated model cannot outperform a training-set mean on regression, the first response should be investigation, not a larger hidden layer.

## 3.11 Schedules and early stopping

A learning-rate schedule changes the step size during training. Step schedules reduce it at specified intervals. Cosine schedules reduce it smoothly over a horizon. Warmup begins with a smaller rate and increases it over early steps. These choices change the optimization trajectory and must be defined in terms of epochs or updates consistently.

Some schedulers are stepped after an epoch; others after every optimizer update. A plateau scheduler consumes a validation metric. Calling all of them at the same arbitrary place can implement the wrong schedule. Document when the scheduler advances and whether the metric is being minimized or maximized.

Early stopping keeps the model from the best validation point rather than the final iteration. A patience parameter controls how long to wait without sufficient improvement. The best parameters must be copied or saved when improvement occurs. Merely assigning `best_state = model.state_dict()` may retain references to tensors that later change.

```python
import copy
import torch
from torch import nn

model = nn.Linear(2, 1)
best_state = copy.deepcopy(model.state_dict())
with torch.no_grad():
    model.weight.add_(1.0)
assert not torch.equal(model.weight, best_state['weight'])
```

This small program demonstrates the state-copying property, not a complete early-stopping loop. A saved checkpoint is another way to preserve the best state. For larger experiments, write atomically where practical so interruption does not leave a partially written artifact presented as valid.

## 3.12 What belongs in a checkpoint

An inference artifact needs enough state to reproduce predictions: model parameters and buffers, architecture configuration, input preprocessing, feature or vocabulary mapping, and output interpretation. A training-resumption checkpoint needs additional state such as optimizer, scheduler, gradient scaler, epoch or update counters, and relevant random generators.

Save a state dictionary rather than serializing an entire arbitrary Python model object as the routine default. The receiving program constructs the architecture explicitly and loads its state. This makes the architecture dependency visible and reduces coupling to a particular Python class location. Loading still requires a trusted provenance and a compatible schema.

```python
import torch
from torch import nn

model = nn.Linear(2, 1)
optimizer = torch.optim.AdamW(model.parameters(), lr=1e-3)
checkpoint = {
    'schema_version': 1,
    'model_config': {'features': 2, 'outputs': 1},
    'model_state': model.state_dict(),
    'optimizer_state': optimizer.state_dict(),
    'epoch': 0,
    'feature_names': ['area', 'temperature'],
}
torch.save(checkpoint, 'regression-checkpoint.pt')
loaded = torch.load('regression-checkpoint.pt', map_location='cpu', weights_only=True)
restored = nn.Linear(loaded['model_config']['features'],
                     loaded['model_config']['outputs'])
restored.load_state_dict(loaded['model_state'])
restored.eval()
```

The example contains tensors and simple primitive containers compatible with the intended restricted load path. Do not assume `weights_only=True` makes every file from every source safe. Avoid loading untrusted model artifacts, and do not disable restrictions merely to suppress an unexplained error. The serialization documentation describes the supported behavior and limitations.

Faithful mid-epoch resumption is more demanding than saving an epoch number. Sampler position, generator state, partially accumulated gradients, and distributed rank state may matter. Decide whether your guarantee is “restart from the last completed epoch” or “continue the exact next batch,” and save the state needed for that guarantee.

## 3.13 A complete standalone regression experiment

The following program runs on CPU or CUDA, creates its own data, fits preprocessing only on training examples, trains a small model, selects the best validation state, and evaluates once on a held-out test partition. Save it as a Python file and run it in the environment prepared in Chapter 1.

```python
import copy
import math
import torch
from torch import nn
from torch.utils.data import TensorDataset, DataLoader

class Pipeline(nn.Module):
    def __init__(self, mean, scale):
        super().__init__()
        self.register_buffer('mean', mean.clone())
        self.register_buffer('scale', scale.clamp_min(1e-6).clone())
        self.network = nn.Sequential(nn.Linear(2, 16), nn.ReLU(), nn.Linear(16, 1))

    def forward(self, features):
        normalized = (features - self.mean) / self.scale
        return self.network(normalized).squeeze(-1)

@torch.no_grad()
def measure(model, loader, device):
    model.eval()
    squared_sum, count = 0.0, 0
    for features, targets in loader:
        features, targets = features.to(device), targets.to(device)
        residual = model(features) - targets
        squared_sum += residual.square().sum().item()
        count += targets.numel()
    return squared_sum / count

def main():
    torch.manual_seed(31)
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    features = torch.randn(600, 2)
    targets = 2 * features[:, 0] - features[:, 1] + 0.3 * features[:, 0].square()
    targets += 0.1 * torch.randn(600)
    permutation = torch.randperm(600)
    train_ids, validation_ids, test_ids = permutation[:400], permutation[400:500], permutation[500:]
    train_x, train_y = features[train_ids], targets[train_ids]
    train_loader = DataLoader(TensorDataset(train_x, train_y), batch_size=32, shuffle=True)
    validation_loader = DataLoader(TensorDataset(features[validation_ids], targets[validation_ids]), batch_size=64)
    test_loader = DataLoader(TensorDataset(features[test_ids], targets[test_ids]), batch_size=64)
    model = Pipeline(train_x.mean(0), train_x.std(0, correction=0)).to(device)
    optimizer = torch.optim.AdamW(model.parameters(), lr=0.01, weight_decay=1e-4)
    best_value, best_state = math.inf, None
    for epoch in range(80):
        model.train()
        for batch_x, batch_y in train_loader:
            batch_x, batch_y = batch_x.to(device), batch_y.to(device)
            optimizer.zero_grad(set_to_none=True)
            prediction = model(batch_x)
            assert prediction.shape == batch_y.shape
            loss = (prediction - batch_y).square().mean()
            if not torch.isfinite(loss):
                raise FloatingPointError('Nonfinite training objective')
            loss.backward()
            optimizer.step()
        validation_mse = measure(model, validation_loader, device)
        if validation_mse < best_value:
            best_value = validation_mse
            best_state = copy.deepcopy(model.state_dict())
        if epoch % 20 == 0:
            print(epoch, validation_mse)
    model.load_state_dict(best_state)
    test_mse = measure(model, test_loader, device)
    print('Test RMSE:', math.sqrt(test_mse))
    cpu_state = {name: value.cpu() for name, value in model.state_dict().items()}
    torch.save({'schema_version': 1, 'model_state': cpu_state,
                'config': {'features': 2, 'hidden': 16},
                'feature_names': ['first_measurement', 'second_measurement']},
               'synthetic-regressor.pt')

if __name__ == '__main__':
    main()
```

The target has a linear component, a small quadratic component, and observation noise. A nonlinear network can model the quadratic component; it should not be expected to predict the independent noise exactly. The random permutation is appropriate for these independently generated synthetic observations. It is not a universal split strategy for real data.

The preprocessing buffers are part of the model state, so the saved artifact carries its coordinate system. Validation chooses weights but test evaluation occurs after selection. CPU state makes the checkpoint convenient to inspect or load on a machine without CUDA. The program prints observed metrics rather than promising one exact score across environments.

## 3.14 Interpreting learning curves as evidence

If training loss decreases and validation loss rises, overfitting is plausible. But first confirm that the two curves use compatible objective definitions and preprocessing. If both are erratic, inspect learning rate, small validation size, random evaluation transforms, and mode settings. If both remain flat, verify parameter updates and target information.

A noisy curve should not automatically trigger a scheduler change. You may be looking at single-batch losses rather than epoch aggregates. Batch composition can vary substantially. Record enough context to know whether a change reflects model behavior, a different sample, or a logging denominator.

Plotting residuals can be more informative than a single scalar. Systematic underprediction for large targets suggests a model or target transformation issue. Errors concentrated in one group suggest missing features, data imbalance, or distribution differences. Neural network debugging should connect numerical symptoms back to observations and assumptions.

## 3.15 A focused failure investigation

Imagine validation performance is unexpectedly excellent. Instead of celebrating immediately, inspect whether the dataset contains duplicates, whether target-derived information entered the features, and whether preprocessing was fitted before splitting. Excellent numbers can be evidence of a bug just as poor numbers can.

Now imagine training works locally but fails with workers enabled. Reduce worker count to zero to recover a direct traceback. Check whether dataset objects are pickleable in the target environment, whether file paths exist in worker processes, and whether random initialization is happening inside item retrieval. Separate the data access problem from the model problem.

Finally, imagine memory grows every epoch. Inspect lists that retain predictions or loss tensors, callbacks that capture graphs, and evaluation without a no-gradient context. Caching allocator behavior can also make reserved GPU memory look different from live tensor memory. Measure the relevant quantity before labeling it a leak.

## 3.16 Class imbalance changes sampling and interpretation

Suppose only one observation in a hundred belongs to the positive class. A shuffled batch of thirty-two examples will often contain no positive examples. This can make positive-class learning slow and metrics noisy. Several interventions are possible, but each changes something different.

A weighted loss increases the contribution of selected classes. A weighted sampler changes which observations the optimizer sees more often. Collecting more representative positive data changes the information available. Moving the decision threshold changes the final decision rule without changing the fitted scores. These should be evaluated separately because their effects on ranking, calibration, and operating costs differ.

Oversampling rare examples does not create new independent information. It repeats their influence. If a rare example is mislabeled, oversampling can amplify that mistake. Combining aggressive oversampling with a heavily weighted positive loss can also overcorrect the effective class balance. State the intended training distribution and inspect the resulting probability behavior.

For a binary objective, `pos_weight` in `BCEWithLogitsLoss` changes positive-label contribution under its documented contract. It is not a generic replacement for every form of sample weighting. Per-example weights can be applied to unreduced losses when the desired objective is explicit. Always inspect the reduction denominator: a weighted sum divided by batch size differs from dividing by total weight.

Evaluation should reflect the expected deployment population. A test set deliberately balanced for convenient analysis may need additional weighting to estimate population-level precision. Recall can remain unchanged under some sampling changes while precision changes because prevalence changes. This is a statistical issue, not a framework defect.

## 3.17 Missing labels are different from negative labels

An absent label may mean that an annotator did not assess the example, rather than that the outcome is negative. Treating all missing entries as zero can train a model to reproduce annotation coverage instead of the intended property. Preserve a separate validity mask and define the objective only over observed targets.

```python
import torch
from torch import nn

logits = torch.tensor([[0.2, -0.4], [1.0, 0.3]], requires_grad=True)
targets = torch.tensor([[1.0, 0.0], [0.0, 1.0]])
observed = torch.tensor([[True, False], [True, True]])
entry_losses = nn.functional.binary_cross_entropy_with_logits(logits, targets, reduction='none')
valid_count = observed.sum()
if valid_count == 0:
    raise ValueError('No observed labels in batch')
loss = entry_losses[observed].mean()
loss.backward()
print(loss.item())
```

Here targets at invalid positions are finite placeholders. That matters: computing an invalid operation and multiplying its result by zero afterward does not reliably remove NaNs or their gradient effects. Validate values before the loss computation or select valid entries before performing an operation that cannot tolerate missing values.

This example averages observed label entries. If examples have different numbers of observed labels, those with more observations receive more total influence. An example-weighted objective would first calculate a valid-label mean within each example and then average across examples with observations. Neither policy is automatically correct; the task determines the intended weighting.

## 3.18 Confidence intervals and repeated comparisons

A held-out metric is an estimate based on a finite sample. If a classifier gets ninety percent accuracy on ten examples, the uncertainty is much larger than ninety percent accuracy on ten thousand independent examples. Point estimates without sample counts hide this distinction.

Bootstrap resampling is one way to assess uncertainty: repeatedly resample evaluation units with replacement and recompute the metric. The resampling unit must match the dependence structure. If many records belong to one patient or customer, resampling individual rows can dramatically understate uncertainty. Resample groups when groups are the independent units.

When comparing two models on the same examples, paired differences often provide more information than unrelated estimates. Both models faced the same difficult and easy cases. A paired analysis preserves that relationship. It still does not compensate for a test set chosen after examining many alternatives.

Multiple experiments create selection effects. If you try enough configurations, one can appear better by chance. Keep an experiment log with the question, changed factor, validation result, and decision. A log is useful evidence for your engineering process, not a requirement to interrupt learning with a formal progress tracker.

## 3.19 Input contracts deserve tests at system boundaries

A model function may accept a tensor successfully even when its columns are wrong. Validate the raw request before tensor construction. Check required fields, units, permitted missing values, category mapping, and plausible numerical ranges. If training used square meters and inference supplies square feet, matching shape and dtype do not rescue the prediction.

For categorical features, store the mapping with the artifact. Unknown categories require a defined policy, such as a dedicated unknown index. Rebuilding the mapping from a deployment batch can assign different identifiers to the same category and silently corrupt predictions. Text vocabulary and image class ordering have the same problem.

A useful parity test takes a few fixed raw examples through both the training-side inference function and the deployed predictor, then compares outputs within a documented tolerance. The test checks the whole preprocessing-to-output path. Comparing only neural network weights would miss a changed normalization constant or reversed class mapping.

Schema versioning helps when an artifact evolves. A loading function should reject an unsupported schema with a useful error rather than guessing at missing fields. Small explicit checks prevent an older service from interpreting a newer model artifact incorrectly.

## 3.20 Designing the next experiment

After the baseline runs, ask one concrete question. For example: does a quadratic target component require additional hidden capacity, or would explicit polynomial features suffice? Compare a linear model, a linear model with a squared feature, and a small neural network under the same split. This teaches more than increasing three hyperparameters simultaneously.

Another useful question is whether more data improves generalization. Train on increasing subsets of the same training partition while keeping validation fixed. If both training and validation errors remain high, capacity or features may be limiting. If the gap narrows as data grows, variance may be a major issue. Learning curves connect the abstract bias-variance discussion to observable behavior.

A third question concerns robustness. Perturb input values within realistic measurement error and examine prediction changes. Large sensitivity can reveal unstable extrapolation even when ordinary test error looks acceptable. Such analysis should use plausible perturbations; arbitrarily destroying inputs says little about expected deployment behavior.

## 3.21 A handoff that another developer can use

A useful model handoff includes a short description of the task, the training population, split policy, input schema, output interpretation, measured metrics, known limitations, artifact version, and an inference example. These details turn a tensor file into an understandable engineering deliverable.

Record the baseline used and the data conditions under which the model improved on it. Report failures as concretely as successes. “Higher error for inputs beyond the training range” is more useful than “may be imperfect.” Include the feature ordering and units next to the inference example so the most likely integration errors are visible at the point of use.

The exact template can be simple. The principle is that another developer should be able to load the artifact, reproduce a few reference predictions, understand the measurements used to assess it, and recognize when incoming data violates its assumptions. That is the foundation for the deployment work in the final chapter.

### What to preserve when the dataset changes

A new dataset revision should be a new experimental condition, even if the training code is identical. Added observations, corrected labels, removed duplicates, and changed preprocessing can alter every result. Store a stable identifier for the exact revision used, and retain enough split information to tell whether an example moved between training and evaluation.

If new labels arrive for previously unobserved outcomes, do not silently add them to the test set after inspecting the model's predictions. Decide how evaluation will evolve and maintain a clear record. Long-lived applications often need a fresh, time-separated evaluation cohort to measure current conditions while retaining an older reference set for regression checks.

Data lineage also helps explain unexpected improvements. A score may increase because labeling became easier or difficult cases were filtered out, rather than because the network improved. Compare population summaries and failure categories alongside aggregate metrics. The objective is not to preserve one number forever; it is to preserve the meaning of the evidence used to make engineering decisions. A model result is always a statement about a particular task, dataset, split, and measurement procedure.

## 3.22 A complete small hyperparameter search

A search trial is an independent experiment, not another epoch of the same model. Recreate model and optimizer state for each trial, keep the data split fixed, and compare validation metrics. This example searches learning rate and hidden width on a generated task without consulting a test set.

```python
import itertools
import torch
from torch import nn

def trial(training_x, training_y, validation_x, validation_y, width, rate):
    torch.manual_seed(101)
    model = nn.Sequential(nn.Linear(2, width), nn.Tanh(), nn.Linear(width, 1))
    optimizer = torch.optim.Adam(model.parameters(), lr=rate)
    for _ in range(80):
        optimizer.zero_grad(set_to_none=True)
        prediction = model(training_x).squeeze(-1)
        loss = (prediction - training_y).square().mean()
        loss.backward()
        optimizer.step()
    model.eval()
    with torch.no_grad():
        residual = model(validation_x).squeeze(-1) - validation_y
        return residual.square().mean().item()

generator = torch.Generator().manual_seed(103)
features = torch.randn(160, 2, generator=generator)
targets = features[:, 0].square() - features[:, 1]
results = []
for width, rate in itertools.product([8, 16], [0.001, 0.01]):
    metric = trial(features[:120], targets[:120], features[120:], targets[120:], width, rate)
    results.append({'width': width, 'rate': rate, 'validation_mse': metric})
print(min(results, key=lambda row: row['validation_mse']))
```

The fixed initialization seed reduces one source of variation within this demonstration. It does not make different widths identical experiments, nor establish statistical superiority from one run. After selecting a promising configuration, repeat enough runs to understand variability if the decision is consequential.

Grid search tries all combinations in a defined grid. Random search samples a search space and can cover influential dimensions more efficiently when many dimensions are unimportant. Bayesian methods use previous trial results to guide later choices, but have overhead and assumptions. Learning rates are often searched on a logarithmic scale because ratios matter across several orders of magnitude.

Record the objective, configuration, seed, resource budget, and artifact for each trial. If some trials receive many more optimizer updates or a larger data subset, their metrics answer a different comparison. Automated search accelerates experimentation; it does not correct an invalid split or make repeated test-set selection legitimate.

## Sources and next step

The official [data utilities](https://docs.pytorch.org/docs/2.15/data.html), [serialization notes](https://docs.pytorch.org/docs/2.15/notes/serialization.html), and [reproducibility notes](https://docs.pytorch.org/docs/2.15/notes/randomness.html) provide API contracts for the engineering above. Accessed November 12, 2026. The next chapter changes the model's inductive bias for spatial and temporal signals while retaining this experiment structure.
