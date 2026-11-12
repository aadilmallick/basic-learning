"""Extracted from lesson 03. See the Markdown chapter for explanation and requirements."""

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
