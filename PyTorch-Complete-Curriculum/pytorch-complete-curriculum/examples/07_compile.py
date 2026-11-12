"""Extracted from lesson 07. See the Markdown chapter for explanation and requirements."""

import torch
from torch import nn

torch.manual_seed(79)
eager = nn.Sequential(nn.Linear(8, 16), nn.ReLU(), nn.Linear(16, 2)).eval()
features = torch.randn(4, 8)
compiled = torch.compile(eager)
with torch.no_grad():
    expected = eager(features)
    actual = compiled(features)
assert torch.allclose(expected, actual, atol=1e-5, rtol=1e-4)
print(actual.shape)
