"""Extracted from lesson 05. See the Markdown chapter for explanation and requirements."""

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
