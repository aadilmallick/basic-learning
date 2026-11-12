"""A complete tiny causal token model; a forward demonstration, not trained NLP."""
import numpy as np
import tensorflow as tf
from tensorflow import keras


@keras.utils.register_keras_serializable(package="Course")
class TokenPosition(keras.layers.Layer):
    def __init__(self, vocabulary_size=32, maximum_length=12, width=16, **kwargs):
        super().__init__(**kwargs)
        self.vocabulary_size = vocabulary_size
        self.maximum_length = maximum_length
        self.width = width
        self.tokens = keras.layers.Embedding(vocabulary_size, width)
        self.positions = keras.layers.Embedding(maximum_length, width)

    def call(self, ids):
        length = tf.shape(ids)[1]
        tf.debugging.assert_less_equal(length, self.maximum_length)
        return self.tokens(ids) + self.positions(tf.range(length))[None, :, :]

    def get_config(self):
        return {
            **super().get_config(), "vocabulary_size": self.vocabulary_size,
            "maximum_length": self.maximum_length, "width": self.width,
        }


@keras.utils.register_keras_serializable(package="Course")
class CausalBlock(keras.layers.Layer):
    def __init__(self, width=16, heads=2, **kwargs):
        super().__init__(**kwargs)
        if width % heads:
            raise ValueError("width must be divisible by heads")
        self.width, self.heads = width, heads
        self.normalizer_one = keras.layers.LayerNormalization(epsilon=1e-5)
        self.normalizer_two = keras.layers.LayerNormalization(epsilon=1e-5)
        self.attention = keras.layers.MultiHeadAttention(heads, width // heads)
        self.feed_forward = keras.Sequential([
            keras.layers.Dense(2 * width, activation="gelu"), keras.layers.Dense(width),
        ])

    def call(self, inputs, training=False):
        values, token_ids = inputs
        valid = token_ids != 0
        allowed = tf.logical_and(valid[:, :, None], valid[:, None, :])
        normalized = self.normalizer_one(values)
        attended = self.attention(
            normalized, normalized, attention_mask=allowed,
            use_causal_mask=True, training=training,
        )
        hidden = values + attended
        result = hidden + self.feed_forward(self.normalizer_two(hidden), training=training)
        return tf.where(valid[:, :, None], result, tf.zeros_like(result))

    def get_config(self):
        return {**super().get_config(), "width": self.width, "heads": self.heads}


def masked_token_loss(targets, logits):
    valid = targets != 0
    per_token = keras.losses.sparse_categorical_crossentropy(targets, logits, from_logits=True)
    weights = tf.cast(valid, per_token.dtype)
    return tf.math.divide_no_nan(tf.reduce_sum(weights * per_token), tf.reduce_sum(weights))


def main():
    keras.utils.set_random_seed(19)
    ids = keras.Input(shape=(None,), dtype="int32", name="token_ids")
    hidden = TokenPosition()(ids)
    hidden = CausalBlock()([hidden, ids])
    logits = keras.layers.Dense(32, name="token_logits")(hidden)
    model = keras.Model(ids, logits)
    complete = tf.constant([[1, 4, 5, 2, 0], [1, 7, 2, 0, 0]], tf.int32)
    inputs, targets = complete[:, :-1], complete[:, 1:]
    outputs = model(inputs, training=False)
    tf.debugging.assert_equal(tf.shape(outputs), [2, 4, 32])
    print("Masked next-token loss:", float(masked_token_loss(targets, outputs).numpy()))
    # Changing only a future token must not change earlier causal outputs.
    first = model(tf.constant([[1, 4, 5, 2]]), training=False).numpy()
    changed_future = model(tf.constant([[1, 4, 9, 2]]), training=False).numpy()
    np.testing.assert_allclose(first[:, :2], changed_future[:, :2], atol=1e-5, rtol=1e-5)
    print("Causal prefix parity passed; outputs remain untrained logits.")


if __name__ == "__main__":
    main()
