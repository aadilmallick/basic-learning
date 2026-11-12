"""Extracted from lesson 06. See the Markdown chapter for explanation and requirements."""

import torch
from torch import nn

class TinyVAE(nn.Module):
    def __init__(self):
        super().__init__()
        self.encoder = nn.Sequential(nn.Linear(2, 16), nn.Tanh())
        self.mean = nn.Linear(16, 2)
        self.log_variance = nn.Linear(16, 2)
        self.decoder = nn.Sequential(nn.Linear(2, 16), nn.Tanh(), nn.Linear(16, 2))
    def forward(self, observations):
        hidden = self.encoder(observations)
        mean = self.mean(hidden)
        log_variance = self.log_variance(hidden).clamp(-8, 8)
        latent = mean + torch.exp(0.5 * log_variance) * torch.randn_like(mean)
        return self.decoder(latent), mean, log_variance

def main():
    torch.manual_seed(61)
    cluster = torch.randint(0, 2, (512, 1)).float()
    observations = torch.cat([2 * cluster - 1, 1 - 2 * cluster], dim=1)
    observations += 0.2 * torch.randn_like(observations)
    model = TinyVAE()
    optimizer = torch.optim.Adam(model.parameters(), lr=0.01)
    for step in range(300):
        indices = torch.randint(0, len(observations), (64,))
        batch = observations[indices]
        reconstruction, mean, log_variance = model(batch)
        reconstruction_term = 0.5 * (reconstruction - batch).square().sum(-1)
        kl = 0.5 * (mean.square() + log_variance.exp() - 1 - log_variance).sum(-1)
        loss = (reconstruction_term + kl).mean()
        optimizer.zero_grad(set_to_none=True)
        loss.backward()
        optimizer.step()
        if step % 100 == 0:
            print(step, loss.item(), reconstruction_term.mean().item(), kl.mean().item())
    model.eval()
    with torch.no_grad():
        generated = model.decoder(torch.randn(5, 2))
    print(generated)

if __name__ == '__main__':
    main()
