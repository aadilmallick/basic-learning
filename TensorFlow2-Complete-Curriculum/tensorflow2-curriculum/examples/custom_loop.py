"""Graph-compiled custom regression loop with per-example metric aggregation."""
import numpy as np
import tensorflow as tf
from tensorflow import keras


def main():
    keras.utils.set_random_seed(31)
    features = tf.random.normal([129, 2])
    targets = 2.0 * features[:, :1] - features[:, 1:2] + 0.5
    dataset = tf.data.Dataset.from_tensor_slices((features, targets)).shuffle(129, seed=31).batch(16)
    model = keras.Sequential([keras.Input(shape=(2,)), keras.layers.Dense(1)])
    optimizer = keras.optimizers.Adam(0.03)
    optimizer.build(model.trainable_variables)
    metric = keras.metrics.Mean()

    @tf.function(input_signature=[tf.TensorSpec([None, 2], tf.float32), tf.TensorSpec([None, 1], tf.float32)])
    def train_step(batch_features, batch_targets):
        with tf.GradientTape() as tape:
            predictions = model(batch_features, training=True)
            per_example = tf.reduce_mean(tf.square(predictions - batch_targets), axis=-1)
            objective = tf.reduce_mean(per_example)
        gradients = tape.gradient(objective, model.trainable_variables)
        optimizer.apply_gradients(zip(gradients, model.trainable_variables))
        return per_example

    initial = float(tf.reduce_mean(tf.square(model(features) - targets)).numpy())
    for epoch in range(35):
        metric.reset_state()
        for batch_features, batch_targets in dataset:
            metric.update_state(train_step(batch_features, batch_targets))
        if epoch % 10 == 0:
            print(epoch, float(metric.result().numpy()))
    final = float(tf.reduce_mean(tf.square(model(features, training=False) - targets)).numpy())
    if not np.isfinite(final) or final >= initial:
        raise AssertionError(f"Training did not improve: {initial} -> {final}")
    print("Initial and final full-data MSE:", initial, final)


if __name__ == "__main__":
    main()
