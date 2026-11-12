"""Recheck lesson depth, Python syntax, Markdown navigation, and numerical derivations."""
import ast
import json
import math
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parent


def anchor(heading):
    return re.sub(r'[^\w\- ]', '', heading.lower()).replace(' ', '-')


def validate():
    lessons = sorted((ROOT / 'lessons').glob('*.md'))
    assert len(lessons) == 7
    lengths = {}
    blocks_count = 0
    sections_count = 0
    for path in lessons:
        content = path.read_text()
        lengths[path.name] = len(content.split())
        assert lengths[path.name] >= 5000, path.name
        blocks = re.findall(r'^```python\n(.*?)^```', content, re.M | re.S)
        for number, code in enumerate(blocks, 1):
            ast.parse(code, filename=f'{path.name}:block{number}')
        blocks_count += len(blocks)
        sections_count += len(re.findall(r'^## \d+\.\d+ ', content, re.M))
        assert not re.search(r'\b(TODO|TBD|FIXME)\b', content)

    scripts = sorted(ROOT.rglob('*.py'))
    for path in scripts:
        ast.parse(path.read_text(), filename=str(path.relative_to(ROOT)))

    link_count = 0
    for path in ROOT.rglob('*.md'):
        content = path.read_text()
        fences = re.findall(r'^```[^\n]*$', content, re.M)
        assert len(fences) % 2 == 0, path
        for target in re.findall(r'\]\(([^)]+)\)', content):
            if '://' in target or target.startswith('mailto:'):
                continue
            relative, _, fragment = target.partition('#')
            linked = (path.parent / relative).resolve() if relative else path
            assert linked.is_file(), (path.name, target)
            if fragment:
                headings = re.findall(r'^#{1,6} (.+)$', linked.read_text(), re.M)
                assert fragment in {anchor(heading) for heading in headings}, (path.name, target)
            link_count += 1

    # Independent scalar/matrix arithmetic checks; these do not execute PyTorch.
    value = 0.0
    losses = []
    for _ in range(8):
        losses.append((value - 3.0) ** 2)
        value -= 0.1 * 2 * (value - 3.0)
    assert all(after < before for before, after in zip(losses, losses[1:]))
    interval = 1e-5
    numerical = (((interval - 3.0) ** 2) - ((-interval - 3.0) ** 2)) / (2 * interval)
    assert math.isclose(numerical, -6.0, abs_tol=1e-8)
    features = [[20.0, 10.0], [40.0, 15.0], [60.0, 20.0]]
    predictions = [sum(a * b for a, b in zip(row, [2.0, -1.0])) + 5 for row in features]
    assert predictions == [35.0, 70.0, 105.0]
    mse = sum((p - t) ** 2 for p, t in zip(predictions, [36, 69, 107])) / 3
    assert mse == 2.0
    image = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
    convolution = [[image[i][j] - image[i+1][j+1] for j in range(2)] for i in range(2)]
    assert convolution == [[-4, -4], [-4, -4]]
    assert math.isclose(0.25 * 10 + 0.75 * 20, 17.5)
    assert math.floor((8 + 2 - (3 - 1) - 1) / 2 + 1) == 4

    return {
        'length_measure': 'whitespace-separated words, Python str.split; not model tokens',
        'per_lesson_minimum': 5000,
        'lesson_word_counts': lengths,
        'total_lesson_words': sum(lengths.values()),
        'numbered_sections': sections_count,
        'python_lesson_blocks_syntax_checked': blocks_count,
        'python_files_syntax_checked': len(scripts),
        'relative_links_checked': link_count,
        'numerical_derivation_checks': 7,
        'pytorch_execution': 'not performed: torch unavailable in authoring environment',
        'tokenizer': 'not available; exact model-token counts not verified',
    }


if __name__ == '__main__':
    print(json.dumps(validate(), indent=2))
