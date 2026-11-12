"""Train, evaluate, save, and reload a small model without external data.

Run: python examples/tabular_capstone.py --output artifacts/tabular
Outputs are local and may be overwritten when using the same output folder.
"""
import argparse
import json
from pathlib import Path

import numpy as np
import tensorflow as tf
from tensorflow import keras


def make_partitions(seed=42):
    generator = np.random.default_rng(seed)
    features = generator.normal(size=(1200, 2)).astype("float32")
    noise = generator.normal(scale=0.25, size=1200)
    labels = (features[:, 0] + 0.7 * features[:, 1] + noise > 0).astype("float32")[:, None]
    order = generator.permutation(len(features))
    partitions = (order[:800], order[800:1000], order[1000:])
    assert not set(partitions[0]) & set(partitions[1])
    assert not set(partitions[0]) & set(partitions[2])
    assert not set(partitions[1]) & set(partitions[2])
    return [(features[ids], labels[ids]) for ids in partitions]


def build_model(training_features):
    normalizer = keras.layers.Normalization(axis=-1, name="training_normalization")
    normalizer.adapt(training_features)
    features = keras.Input(shape=(2,), name="features")
    hidden = normalizer(features)
    hidden = keras.layers.Dense(16, activation="relu")(hidden)
    logit = keras.layers.Dense(1, name="logit")(hidden)
    model = keras.Model(features, logit)
    model.compile(
        optimizer=keras.optimizers.Adam(0.01),
        loss=keras.losses.BinaryCrossentropy(from_logits=True),
        metrics=[keras.metrics.BinaryAccuracy(name="accuracy", threshold=0.0)],
        jit_compile=False,
    )
    return model


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", type=Path, default=Path("artifacts/tabular"))
    parser.add_argument("--export", action="store_true", help="Also export a SavedModel.")
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    keras.utils.set_random_seed(42)
    (x_train, y_train), (x_val, y_val), (x_test, y_test) = make_partitions()
    model = build_model(x_train)
    best_path = args.output / "best.keras"
    history = model.fit(
        x_train, y_train,
        validation_data=(x_val, y_val),
        epochs=60, batch_size=32, verbose=0,
        callbacks=[
            keras.callbacks.EarlyStopping(monitor="val_loss", patience=7),
            keras.callbacks.ModelCheckpoint(str(best_path), monitor="val_loss", save_best_only=True),
            keras.callbacks.TerminateOnNaN(),
        ],
    )
    # Reload the full selected checkpoint, including its optimizer state.
    model = keras.models.load_model(best_path)
    test_metrics = model.evaluate(x_test, y_test, verbose=0, return_dict=True)
    logits = model(x_test[:8], training=False).numpy()
    final_path = args.output / "classifier.keras"
    model.save(final_path)
    restored = keras.models.load_model(final_path)
    np.testing.assert_allclose(
        logits, restored(x_test[:8], training=False).numpy(), rtol=1e-5, atol=1e-6,
    )
    majority = max(float(np.mean(y_test)), 1.0 - float(np.mean(y_test)))
    report = {
        "tensorflow": tf.__version__, "keras": keras.__version__,
        "seed": 42, "epochs_run": len(history.history["loss"]),
        "partition_sizes": [800, 200, 200],
        "test": {name: float(value) for name, value in test_metrics.items()},
        "test_majority_baseline_accuracy": majority,
        "probe_probabilities": tf.math.sigmoid(logits).numpy().tolist(),
        "reload_parity": "passed", "schema": {"features": ["synthetic_0", "synthetic_1"]},
    }
    (args.output / "report.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    if args.export:
        model.export(str(args.output / "savedmodel"))
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
