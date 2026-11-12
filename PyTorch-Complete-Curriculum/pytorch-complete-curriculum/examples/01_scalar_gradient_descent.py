"""Extracted from lesson 02. See the Markdown chapter for explanation and requirements."""

weight = 0.0
learning_rate = 0.1
for iteration in range(8):
    loss = (weight - 3.0) ** 2
    gradient = 2 * (weight - 3.0)
    print(iteration, round(weight, 4), round(loss, 4))
    weight -= learning_rate * gradient
