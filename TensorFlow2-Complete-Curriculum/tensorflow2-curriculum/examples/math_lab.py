"""Run from the course root: python examples/math_lab.py."""
import numpy as np
import tensorflow as tf
from tensorflow import keras


def main():
    print("TensorFlow", tf.__version__, "Keras", keras.__version__)
    features = tf.constant([[2.0, -1.0], [0.0, 1.0], [1.0, 1.0]])
    predictions = features @ tf.constant([[0.5], [3.0]]) + tf.constant([1.0])
    np.testing.assert_allclose(predictions.numpy(), [[-1.0], [4.0], [4.5]])

    weight = tf.Variable(1.0)
    bias = tf.Variable(0.0)
    with tf.GradientTape() as tape:
        loss = tf.square(2.0 * weight + bias - 5.0)
    dw, db = tape.gradient(loss, [weight, bias])
    np.testing.assert_allclose([dw.numpy(), db.numpy()], [-12.0, -6.0])
    weight.assign_sub(0.1 * dw)
    bias.assign_sub(0.1 * db)
    np.testing.assert_allclose((2.0 * weight + bias).numpy(), 5.0, atol=1e-6)
    print("Forward and gradient checks passed.")


if __name__ == "__main__":
    main()
