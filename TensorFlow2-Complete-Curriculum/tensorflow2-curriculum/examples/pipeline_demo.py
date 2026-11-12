"""Create local image/text/record inputs and inspect transformed batches."""
from pathlib import Path
import tempfile

import tensorflow as tf
from tensorflow import keras


def main():
    with tempfile.TemporaryDirectory() as temporary:
        folder = Path(temporary)
        image_path = folder / "sample.jpg"
        pixels = tf.ones([8, 8, 3], tf.uint8) * 127
        tf.io.write_file(str(image_path), tf.io.encode_jpeg(pixels))

        def decode(filename, label):
            image = tf.io.decode_jpeg(tf.io.read_file(filename), channels=3)
            image = tf.image.convert_image_dtype(image, tf.float32)
            image = tf.image.resize(image, [16, 16])
            return tf.ensure_shape(image, [16, 16, 3]), label

        images = tf.data.Dataset.from_tensor_slices(([str(image_path)], [1]))
        images = images.map(decode).batch(1)
        batch, labels = next(iter(images))
        tf.debugging.assert_equal(tf.shape(batch), [1, 16, 16, 3])
        print("Image batch:", batch.shape, labels.numpy())

        text = tf.constant(["models learn", "good data matters"])
        vectorizer = keras.layers.TextVectorization(output_mode="int", output_sequence_length=4)
        vectorizer.adapt(text)
        print("Text IDs:", vectorizer(text).numpy())

        record = tf.train.Example(features=tf.train.Features(feature={
            "label": tf.train.Feature(int64_list=tf.train.Int64List(value=[1])),
        }))
        record_path = folder / "tiny.tfrecord"
        with tf.io.TFRecordWriter(str(record_path)) as writer:
            writer.write(record.SerializeToString())
        records = tf.data.TFRecordDataset([str(record_path)])
        parsed = tf.io.parse_single_example(
            next(iter(records)), {"label": tf.io.FixedLenFeature([], tf.int64)},
        )
        tf.debugging.assert_equal(parsed["label"], tf.constant(1, tf.int64))
        print("Record label:", parsed["label"].numpy())


if __name__ == "__main__":
    main()
