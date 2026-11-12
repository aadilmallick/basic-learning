"""Extracted from lesson 05. See the Markdown chapter for explanation and requirements."""

import torch
from torch import nn
from torch.nn import functional as F

class CausalAttention(nn.Module):
    def __init__(self, width, heads, dropout=0.1):
        super().__init__()
        if width % heads:
            raise ValueError('Width must be divisible by heads')
        self.heads = heads
        self.head_width = width // heads
        self.qkv = nn.Linear(width, 3 * width)
        self.output = nn.Linear(width, width)
        self.dropout = dropout
    def forward(self, features):
        batch, length, width = features.shape
        query, key, value = self.qkv(features).chunk(3, dim=-1)
        def split(tensor):
            return tensor.reshape(batch, length, self.heads,
                                  self.head_width).transpose(1, 2)
        attended = F.scaled_dot_product_attention(
            split(query), split(key), split(value), is_causal=True,
            dropout_p=self.dropout if self.training else 0.0)
        combined = attended.transpose(1, 2).reshape(batch, length, width)
        return self.output(combined)

class Block(nn.Module):
    def __init__(self, width, heads):
        super().__init__()
        self.norm1 = nn.LayerNorm(width)
        self.attention = CausalAttention(width, heads)
        self.norm2 = nn.LayerNorm(width)
        self.feedforward = nn.Sequential(nn.Linear(width, 4 * width),
                                         nn.GELU(), nn.Linear(4 * width, width))
    def forward(self, features):
        features = features + self.attention(self.norm1(features))
        return features + self.feedforward(self.norm2(features))

class TinyLanguageModel(nn.Module):
    def __init__(self, vocabulary_size, context=24, width=32, heads=4):
        super().__init__()
        self.context = context
        self.tokens = nn.Embedding(vocabulary_size, width)
        self.positions = nn.Embedding(context, width)
        self.blocks = nn.Sequential(Block(width, heads), Block(width, heads))
        self.norm = nn.LayerNorm(width)
        self.head = nn.Linear(width, vocabulary_size)
    def forward(self, token_ids):
        batch, length = token_ids.shape
        if length > self.context:
            raise ValueError('Sequence exceeds context')
        positions = torch.arange(length, device=token_ids.device)
        features = self.tokens(token_ids) + self.positions(positions)
        return self.head(self.norm(self.blocks(features)))

@torch.no_grad()
def generate(model, prefix, additional_tokens, temperature=1.0):
    if temperature <= 0:
        raise ValueError('Temperature must be positive')
    model.eval()
    sequence = prefix.clone()
    for _ in range(additional_tokens):
        logits = model(sequence[:, -model.context:])[:, -1, :]
        probabilities = (logits / temperature).softmax(dim=-1)
        next_token = torch.multinomial(probabilities, num_samples=1)
        sequence = torch.cat([sequence, next_token], dim=1)
    return sequence

def main():
    torch.manual_seed(53)
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    text = ('small models learn from data. data shapes learning. ' * 50)
    characters = sorted(set(text))
    to_id = {character: index for index, character in enumerate(characters)}
    data = torch.tensor([to_id[character] for character in text], dtype=torch.long)
    split = int(0.9 * len(data))
    training, validation = data[:split], data[split:]
    model = TinyLanguageModel(len(characters)).to(device)
    optimizer = torch.optim.AdamW(model.parameters(), lr=2e-3)
    def batch(source):
        starts = torch.randint(0, len(source) - model.context, (8,))
        inputs = torch.stack([source[start:start + model.context] for start in starts])
        targets = torch.stack([source[start + 1:start + model.context + 1] for start in starts])
        return inputs.to(device), targets.to(device)
    for step in range(150):
        model.train()
        inputs, targets = batch(training)
        optimizer.zero_grad(set_to_none=True)
        logits = model(inputs)
        loss = F.cross_entropy(logits.reshape(-1, len(characters)), targets.reshape(-1))
        loss.backward()
        optimizer.step()
        if step % 50 == 0:
            model.eval()
            with torch.no_grad():
                val_inputs, val_targets = batch(validation)
                val_logits = model(val_inputs)
                val_loss = F.cross_entropy(val_logits.reshape(-1, len(characters)),
                                            val_targets.reshape(-1))
            print(step, loss.detach().item(), val_loss.item())
    prefix = torch.tensor([[to_id['s']]], device=device)
    generated = generate(model, prefix, 80)
    print(''.join(characters[index] for index in generated[0].cpu().tolist()))

if __name__ == '__main__':
    main()
