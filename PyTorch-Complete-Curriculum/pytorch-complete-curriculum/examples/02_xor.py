"""Extracted from lesson 02. See the Markdown chapter for explanation and requirements."""

import torch
from torch import nn

torch.manual_seed(19)
features = torch.tensor([[0.0, 0.0], [0.0, 1.0],
                         [1.0, 0.0], [1.0, 1.0]])
targets = torch.tensor([0.0, 1.0, 1.0, 0.0])
model = nn.Sequential(nn.Linear(2, 16), nn.Tanh(), nn.Linear(16, 1))
optimizer = torch.optim.Adam(model.parameters(), lr=0.03)
criterion = nn.BCEWithLogitsLoss()

for iteration in range(1500):
    optimizer.zero_grad(set_to_none=True)
    logits = model(features).squeeze(-1)
    loss = criterion(logits, targets)
    loss.backward()
    optimizer.step()

model.eval()
with torch.no_grad():
    probabilities = model(features).squeeze(-1).sigmoid()
    print(probabilities)
    print((probabilities >= 0.5).long())
