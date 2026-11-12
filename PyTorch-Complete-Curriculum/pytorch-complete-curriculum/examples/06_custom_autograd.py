"""Extracted from lesson 06. See the Markdown chapter for explanation and requirements."""

import torch

class Square(torch.autograd.Function):
    @staticmethod
    def forward(ctx, inputs):
        ctx.save_for_backward(inputs)
        return inputs.square()
    @staticmethod
    def backward(ctx, upstream):
        (inputs,) = ctx.saved_tensors
        return upstream * 2 * inputs

inputs = torch.tensor([1.5, -2.0], dtype=torch.float64, requires_grad=True)
outputs = Square.apply(inputs)
outputs.sum().backward()
print(inputs.grad)
check_inputs = torch.randn(3, dtype=torch.float64, requires_grad=True)
assert torch.autograd.gradcheck(Square.apply, (check_inputs,))
