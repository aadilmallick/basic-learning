"""Extracted from lesson 06. See the Markdown chapter for explanation and requirements."""

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
