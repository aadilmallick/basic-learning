"""Extracted from lesson 06. See the Markdown chapter for explanation and requirements."""

import torch
from torch import nn
from torch.distributions import Categorical

torch.manual_seed(71)
logits = nn.Parameter(torch.zeros(3))
optimizer = torch.optim.Adam([logits], lr=0.05)
reward_means = torch.tensor([0.0, 0.5, 1.0])
baseline = 0.0
for step in range(400):
    policy = Categorical(logits=logits)
    action = policy.sample()
    reward = reward_means[action] + 0.2 * torch.randn(())
    advantage = reward - baseline
    loss = -policy.log_prob(action) * advantage.detach()
    optimizer.zero_grad(set_to_none=True)
    loss.backward()
    optimizer.step()
    baseline = 0.95 * baseline + 0.05 * reward.item()
print(logits.softmax(-1).detach())
