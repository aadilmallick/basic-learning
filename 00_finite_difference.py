"""Extracted from lesson 02. See the Markdown chapter for explanation and requirements."""

def objective(weight):
    return (weight - 3.0) ** 2

weight = 0.0
step = 1e-5
finite_difference = (objective(weight + step) - objective(weight - step)) / (2 * step)
exact_derivative = 2 * (weight - 3.0)
print(finite_difference)
print(exact_derivative)
