"""Extracted from lesson 04. See the Markdown chapter for explanation and requirements."""

import torch
from torch import nn
from torch.utils.data import TensorDataset, DataLoader

def make_bars(count, seed):
    generator = torch.Generator().manual_seed(seed)
    labels = torch.randint(0, 2, (count,), generator=generator)
    images = 0.08 * torch.randn(count, 1, 16, 16, generator=generator)
    positions = torch.randint(2, 12, (count,), generator=generator)
    for index in range(count):
        position = int(positions[index])
        if int(labels[index]) == 0:
            images[index, 0, :, position:position + 2] += 1.0
        else:
            images[index, 0, position:position + 2, :] += 1.0
    return TensorDataset(images, labels)

class BarClassifier(nn.Module):
    def __init__(self):
        super().__init__()
        self.features = nn.Sequential(
            nn.Conv2d(1, 8, 3, padding=1), nn.ReLU(), nn.MaxPool2d(2),
            nn.Conv2d(8, 16, 3, padding=1), nn.ReLU(),
            nn.AdaptiveAvgPool2d(1),
        )
        self.classifier = nn.Linear(16, 2)
    def forward(self, images):
        return self.classifier(self.features(images).flatten(1))

@torch.no_grad()
def accuracy(model, loader, device):
    model.eval()
    correct, count = 0, 0
    for images, labels in loader:
        images, labels = images.to(device), labels.to(device)
        correct += (model(images).argmax(-1) == labels).sum().item()
        count += len(labels)
    return correct / count

def main():
    torch.manual_seed(41)
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    training = DataLoader(make_bars(512, 1), batch_size=32, shuffle=True)
    validation = DataLoader(make_bars(128, 2), batch_size=64)
    model = BarClassifier().to(device)
    optimizer = torch.optim.Adam(model.parameters(), lr=0.01)
    for epoch in range(8):
        model.train()
        for images, labels in training:
            images, labels = images.to(device), labels.to(device)
            optimizer.zero_grad(set_to_none=True)
            logits = model(images)
            loss = nn.functional.cross_entropy(logits, labels)
            loss.backward()
            optimizer.step()
        print(epoch, accuracy(model, validation, device))

if __name__ == '__main__':
    main()
