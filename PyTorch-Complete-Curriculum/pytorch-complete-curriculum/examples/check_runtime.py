"""CPU runtime checks to run after installing PyTorch; not executed during authoring."""
import importlib.util
from pathlib import Path
import tempfile
import torch
from torch.nn import functional as F
from capstone import Predictor, predict_rows, load_predictor


def load_example(filename):
    path = Path(__file__).with_name(filename)
    spec = importlib.util.spec_from_file_location(path.stem, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def main():
    torch.manual_seed(109)
    weight = torch.tensor(2.0, requires_grad=True)
    (2 * weight + 1).square().backward()
    assert weight.grad.item() == 20.0

    logits = torch.randn(2, 3, 4, requires_grad=True)
    labels = torch.tensor([[0, 1, 2], [3, 1, -100]])
    loss = F.cross_entropy(logits.reshape(-1, 4), labels.reshape(-1), ignore_index=-100)
    loss.backward()
    assert torch.equal(logits.grad[1, 2], torch.zeros(4))

    language = load_example('05_tiny_transformer.py').TinyLanguageModel(12).eval()
    first = torch.tensor([[1, 2, 3, 4, 5]])
    changed = torch.tensor([[1, 2, 3, 9, 8]])
    with torch.no_grad():
        assert torch.allclose(language(first)[:, :3], language(changed)[:, :3],
                              atol=1e-6, rtol=1e-5)

    vision = load_example('04_cnn_bars.py').BarClassifier()
    image_logits = vision(torch.randn(2, 1, 16, 16))
    assert image_logits.shape == (2, 2)
    F.cross_entropy(image_logits, torch.tensor([0, 1])).backward()
    assert all(parameter.grad is not None for parameter in vision.parameters())

    vae = load_example('06_tiny_vae.py').TinyVAE()
    reconstruction, mean, log_variance = vae(torch.randn(5, 2))
    objective = (reconstruction.square().sum(-1) +
                 0.5 * (mean.square() + log_variance.exp() - 1 - log_variance).sum(-1)).mean()
    objective.backward()
    assert all(torch.isfinite(parameter.grad).all() for parameter in vae.parameters())

    predictor = Predictor(torch.tensor([1.0, 2.0]), torch.tensor([0.5, 0.8])).eval()
    rows = [[1.0, 2.0], [0.0, -1.0]]
    with tempfile.TemporaryDirectory() as temporary:
        path = Path(temporary) / 'model.pt'
        torch.save({'schema_version': 1, 'width': 16,
                    'feature_names': ['area', 'temperature'],
                    'model_state': predictor.state_dict()}, path)
        restored = load_predictor(path)
        assert torch.allclose(torch.tensor(predict_rows(predictor, rows)),
                              torch.tensor(predict_rows(restored, rows)))
    for invalid in ([], [[1.0]], [[float('nan'), 2.0]]):
        try:
            predict_rows(predictor, invalid)
        except ValueError:
            pass
        else:
            raise AssertionError('Invalid input was accepted')
    print('CPU runtime checks passed:', torch.__version__)


if __name__ == '__main__':
    main()
