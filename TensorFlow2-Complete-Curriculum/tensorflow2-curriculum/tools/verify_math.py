"""Independent NumPy checks of selected lesson calculations; no TensorFlow."""
import numpy as np


def main():
    features = np.array([[2.0, -1.0], [0.0, 1.0], [1.0, 1.0]])
    np.testing.assert_allclose(features @ np.array([[0.5], [3.0]]) + 1, [[-1], [4], [4.5]])

    # Wrong target axis creates all-pairs residuals rather than paired residuals.
    prediction = np.array([[1.0], [2.0], [3.0]])
    target = np.array([1.0, 2.0, 3.0])
    assert (prediction - target).shape == (3, 3)
    assert (prediction - target[:, None]).shape == (3, 1)

    # Central difference verifies the derived scalar squared-error gradient.
    objective = lambda weight: (2 * weight - 5) ** 2
    epsilon, weight = 1e-5, 1.3
    numerical = (objective(weight + epsilon) - objective(weight - epsilon)) / (2 * epsilon)
    np.testing.assert_allclose(numerical, 4 * (2 * weight - 5), rtol=1e-8)
    np.testing.assert_allclose(2 * (1 - 0.1 * -12) + (0 - 0.1 * -6), 5.0)

    # Stable binary cross-entropy from logits.
    labels, logits = np.array([1.0, 0.0]), np.array([2.0, -2.0])
    bce = np.maximum(logits, 0) - logits * labels + np.log1p(np.exp(-np.abs(logits)))
    np.testing.assert_allclose(bce.mean(), 0.1269280110429725)

    # Dense-layer analytic gradients checked against finite differences.
    rng = np.random.default_rng(5)
    inputs, kernel, targets = rng.normal(size=(4, 2)), rng.normal(size=(2, 3)), rng.normal(size=(4, 3))
    residual = inputs @ kernel - targets
    analytic = inputs.T @ (2 * residual / residual.size)
    numerical_kernel = np.zeros_like(kernel)
    for index in np.ndindex(kernel.shape):
        high, low = kernel.copy(), kernel.copy()
        high[index] += epsilon
        low[index] -= epsilon
        numerical_kernel[index] = (
            np.mean((inputs @ high - targets) ** 2) - np.mean((inputs @ low - targets) ** 2)
        ) / (2 * epsilon)
    np.testing.assert_allclose(analytic, numerical_kernel, atol=1e-8)

    # Reduction weighting for unequal batches.
    np.testing.assert_allclose((100 * 0.2 + 10 * 0.8) / 110, 0.2545454545454545)
    assert not np.isclose((0.2 + 0.8) / 2, (100 * 0.2 + 10 * 0.8) / 110)

    # ReLU forward lab and convolution arithmetic.
    scaled = np.array([[-1.0, -1.0], [1.0, 1.0]])
    hidden = np.maximum(0, scaled @ np.array([[1.0, -1.0], [1.0, 1.0]]))
    np.testing.assert_allclose(hidden @ np.array([[0.5], [1.0]]) + 2, [[2], [3]])
    np.testing.assert_allclose(np.sum(np.array([[1, 2], [3, 4]]) * np.array([[1, 0], [0, -1]])), -3)

    # Attention probabilities normalize, and constant logit shifts cancel.
    scores = np.array([1.0, 0.0]) / np.sqrt(2.0)
    softmax = lambda values: np.exp(values - values.max()) / np.exp(values - values.max()).sum()
    probabilities = softmax(scores)
    np.testing.assert_allclose(probabilities.sum(), 1)
    np.testing.assert_allclose(softmax(scores + 1000), probabilities)
    context = probabilities @ np.array([[10.0, 0.0], [0.0, 20.0]])
    assert context.shape == (2,) and context[0] > 5 and context[1] < 10

    print("Independent numerical checks passed: forward pass, shapes, scalar and dense gradients,")
    print("stable BCE, batch weighting, convolution, attention, and softmax invariance.")


if __name__ == "__main__":
    main()
