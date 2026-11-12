"""Extracted from lesson 07. See the Markdown chapter for explanation and requirements."""

import torch
from torch import nn

model = nn.Sequential(nn.Linear(3, 8), nn.ReLU(), nn.Linear(8, 1)).eval()
example = torch.randn(2, 3)
program = torch.export.export(model, (example,))
torch.export.save(program, 'regressor.pt2')
loaded = torch.export.load('regressor.pt2')
with torch.no_grad():
    expected = model(example)
    actual = loaded.module()(example)
assert torch.allclose(expected, actual)
