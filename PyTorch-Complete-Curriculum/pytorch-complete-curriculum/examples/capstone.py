"""Extracted from lesson 07. See the Markdown chapter for explanation and requirements."""

import copy
import math
from pathlib import Path
import torch
from torch import nn
from torch.utils.data import TensorDataset, DataLoader

class Predictor(nn.Module):
    def __init__(self, mean, scale, width=16):
        super().__init__()
        self.register_buffer('mean', mean.clone())
        self.register_buffer('scale', scale.clamp_min(1e-6).clone())
        self.network = nn.Sequential(nn.Linear(2, width), nn.Tanh(), nn.Linear(width, 1))
    def forward(self, features):
        return self.network((features - self.mean) / self.scale).squeeze(-1)

@torch.no_grad()
def mse(model, features, targets):
    model.eval()
    return (model(features) - targets).square().mean().item()

def load_predictor(path):
    artifact = torch.load(path, map_location='cpu', weights_only=True)
    if artifact['schema_version'] != 1:
        raise ValueError('Unsupported artifact schema')
    if artifact['feature_names'] != ['area', 'temperature']:
        raise ValueError('Unexpected feature contract')
    state = artifact['model_state']
    model = Predictor(torch.zeros(2), torch.ones(2), width=artifact['width'])
    model.load_state_dict(state)
    return model.eval()

@torch.inference_mode()
def predict_rows(model, rows):
    values = torch.as_tensor(rows, dtype=torch.float32)
    if values.ndim != 2 or values.shape[1] != 2 or values.shape[0] == 0:
        raise ValueError('Expected nonempty rows [area, temperature]')
    if not torch.isfinite(values).all():
        raise ValueError('Inputs must be finite')
    return model(values).tolist()

def main():
    torch.manual_seed(89)
    generator = torch.Generator().manual_seed(97)
    features = torch.randn(500, 2, generator=generator)
    targets = 1.5 * features[:, 0] - 0.7 * features[:, 1]
    targets += 0.2 * features[:, 0].square()
    targets += 0.05 * torch.randn(500, generator=generator)
    train_x, train_y = features[:350], targets[:350]
    val_x, val_y = features[350:425], targets[350:425]
    test_x, test_y = features[425:], targets[425:]
    model = Predictor(train_x.mean(0), train_x.std(0, correction=0))
    optimizer = torch.optim.AdamW(model.parameters(), lr=0.01, weight_decay=1e-4)
    loader = DataLoader(TensorDataset(train_x, train_y), batch_size=32, shuffle=True)
    best_metric, best_state = math.inf, None
    for epoch in range(60):
        model.train()
        for batch_x, batch_y in loader:
            optimizer.zero_grad(set_to_none=True)
            loss = (model(batch_x) - batch_y).square().mean()
            if not torch.isfinite(loss):
                raise FloatingPointError('Nonfinite objective')
            loss.backward()
            optimizer.step()
        metric = mse(model, val_x, val_y)
        if metric < best_metric:
            best_metric, best_state = metric, copy.deepcopy(model.state_dict())
    model.load_state_dict(best_state)
    model.eval()
    print('Test MSE:', mse(model, test_x, test_y))
    baseline = (test_y - train_y.mean()).square().mean().item()
    print('Training-mean baseline MSE:', baseline)
    artifact = {'schema_version': 1, 'width': 16,
                'feature_names': ['area', 'temperature'],
                'model_state': model.state_dict()}
    path = Path('capstone-model.pt')
    torch.save(artifact, path)
    restored = load_predictor(path)
    reference_rows = [[0.0, 0.0], [1.0, -1.0], [-0.5, 0.8]]
    expected = torch.tensor(predict_rows(model, reference_rows))
    actual = torch.tensor(predict_rows(restored, reference_rows))
    assert torch.allclose(expected, actual, atol=1e-6, rtol=1e-5)
    print('Reload parity passed:', actual.tolist())
    try:
        predict_rows(restored, [[float('nan'), 0.0]])
    except ValueError:
        print('Invalid-input rejection passed')
    else:
        raise AssertionError('Expected invalid-input rejection')

if __name__ == '__main__':
    main()
