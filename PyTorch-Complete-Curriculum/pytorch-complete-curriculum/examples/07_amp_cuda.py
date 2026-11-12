"""Extracted from lesson 07. See the Markdown chapter for explanation and requirements."""

import torch
from torch import nn

if not torch.cuda.is_available():
    raise RuntimeError('This mixed-precision example requires CUDA')
model = nn.Linear(16, 4).cuda()
optimizer = torch.optim.AdamW(model.parameters(), lr=1e-3)
scaler = torch.amp.GradScaler('cuda')
features = torch.randn(32, 16, device='cuda')
targets = torch.randint(0, 4, (32,), device='cuda')
optimizer.zero_grad(set_to_none=True)
with torch.autocast(device_type='cuda', dtype=torch.float16):
    logits = model(features)
    loss = nn.functional.cross_entropy(logits, targets)
scaler.scale(loss).backward()
scaler.unscale_(optimizer)
nn.utils.clip_grad_norm_(model.parameters(), max_norm=1.0)
scaler.step(optimizer)
scaler.update()
print(loss.detach().item())
