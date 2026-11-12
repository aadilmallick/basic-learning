"""Extracted from lesson 07. See the Markdown chapter for explanation and requirements."""

import torch
from torch import nn
import torch.distributed as dist
from torch.nn.parallel import DistributedDataParallel
from torch.utils.data import TensorDataset, DataLoader, DistributedSampler

def main():
    dist.init_process_group(backend='gloo')
    try:
        rank = dist.get_rank()
        torch.manual_seed(83)
        features = torch.randn(64, 2)
        targets = 2 * features[:, 0] - features[:, 1]
        dataset = TensorDataset(features, targets)
        sampler = DistributedSampler(dataset, shuffle=True, drop_last=False)
        loader = DataLoader(dataset, batch_size=8, sampler=sampler)
        model = DistributedDataParallel(nn.Linear(2, 1))
        optimizer = torch.optim.SGD(model.parameters(), lr=0.05)
        for epoch in range(10):
            sampler.set_epoch(epoch)
            model.train()
            local_sum = torch.zeros((), dtype=torch.float64)
            local_count = torch.zeros((), dtype=torch.float64)
            for batch_x, batch_y in loader:
                optimizer.zero_grad(set_to_none=True)
                residual = model(batch_x).squeeze(-1) - batch_y
                loss = residual.square().mean()
                loss.backward()
                optimizer.step()
                local_sum += residual.detach().square().sum().double()
                local_count += len(batch_y)
            dist.all_reduce(local_sum, op=dist.ReduceOp.SUM)
            dist.all_reduce(local_count, op=dist.ReduceOp.SUM)
            if rank == 0:
                print(epoch, (local_sum / local_count).item())
        if rank == 0:
            torch.save(model.module.state_dict(), 'ddp-weights.pt')
    finally:
        dist.destroy_process_group()

if __name__ == '__main__':
    main()
