"""Extracted from lesson 03. See the Markdown chapter for explanation and requirements."""

import copy
import math
import torch
from torch import nn
from torch.utils.data import TensorDataset, DataLoader

class Pipeline(nn.Module):
    def __init__(self, mean, scale):
        super().__init__()
        self.register_buffer('mean', mean.clone())
        self.register_buffer('scale', scale.clamp_min(1e-6).clone())
        self.network = nn.Sequential(nn.Linear(2, 16), nn.ReLU(), nn.Linear(16, 1))

    def forward(self, features):
        normalized = (features - self.mean) / self.scale
        return self.network(normalized).squeeze(-1)

@torch.no_grad()
def measure(model, loader, device):
    model.eval()
    squared_sum, count = 0.0, 0
    for features, targets in loader:
        features, targets = features.to(device), targets.to(device)
        residual = model(features) - targets
        squared_sum += residual.square().sum().item()
        count += targets.numel()
    return squared_sum / count

def main():
    torch.manual_seed(31)
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    features = torch.randn(600, 2)
    targets = 2 * features[:, 0] - features[:, 1] + 0.3 * features[:, 0].square()
    targets += 0.1 * torch.randn(600)
    permutation = torch.randperm(600)
    train_ids, validation_ids, test_ids = permutation[:400], permutation[400:500], permutation[500:]
    train_x, train_y = features[train_ids], targets[train_ids]
    train_loader = DataLoader(TensorDataset(train_x, train_y), batch_size=32, shuffle=True)
    validation_loader = DataLoader(TensorDataset(features[validation_ids], targets[validation_ids]), batch_size=64)
    test_loader = DataLoader(TensorDataset(features[test_ids], targets[test_ids]), batch_size=64)
    model = Pipeline(train_x.mean(0), train_x.std(0, correction=0)).to(device)
    optimizer = torch.optim.AdamW(model.parameters(), lr=0.01, weight_decay=1e-4)
    best_value, best_state = math.inf, None
    for epoch in range(80):
        model.train()
        for batch_x, batch_y in train_loader:
            batch_x, batch_y = batch_x.to(device), batch_y.to(device)
            optimizer.zero_grad(set_to_none=True)
            prediction = model(batch_x)
            assert prediction.shape == batch_y.shape
            loss = (prediction - batch_y).square().mean()
            if not torch.isfinite(loss):
                raise FloatingPointError('Nonfinite training objective')
            loss.backward()
            optimizer.step()
        validation_mse = measure(model, validation_loader, device)
        if validation_mse < best_value:
            best_value = validation_mse
            best_state = copy.deepcopy(model.state_dict())
        if epoch % 20 == 0:
            print(epoch, validation_mse)
    model.load_state_dict(best_state)
    test_mse = measure(model, test_loader, device)
    print('Test RMSE:', math.sqrt(test_mse))
    cpu_state = {name: value.cpu() for name, value in model.state_dict().items()}
    torch.save({'schema_version': 1, 'model_state': cpu_state,
                'config': {'features': 2, 'hidden': 16},
                'feature_names': ['first_measurement', 'second_measurement']},
               'synthetic-regressor.pt')

if __name__ == '__main__':
    main()
