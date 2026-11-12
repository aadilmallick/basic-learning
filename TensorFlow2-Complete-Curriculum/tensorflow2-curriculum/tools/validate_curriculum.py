"""Validate package structure, word proxy, fenced Python syntax, and local links."""
import ast
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]


def main():
    failures, counts = [], {}
    block_count = 0
    lessons = sorted((ROOT / "lessons").glob("*.md"))
    if len(lessons) != 5:
        failures.append(f"Expected 5 lessons; found {len(lessons)}")
    for path in sorted(ROOT.rglob("*.md")):
        text = path.read_text(encoding="utf-8")
        fences = re.findall(r"^```.*$", text, re.M)
        if len(fences) % 2:
            failures.append(f"Unbalanced fence: {path.relative_to(ROOT)}")
        if path in lessons:
            counts[path.name] = len(text.split())
            if counts[path.name] < 5000:
                failures.append(f"Below 5000-word proxy: {path.name}")
        for index, code in enumerate(re.findall(r"```python\n(.*?)\n```", text, re.S), 1):
            block_count += 1
            try:
                ast.parse(code)
            except SyntaxError as error:
                failures.append(f"Invalid Python in {path.name}, block {index}: {error}")
        # Only local file links; external URLs and heading-only links are excluded.
        link_text = re.sub(r"^```[^\n]*\n.*?^```[ \t]*$", "", text, flags=re.M | re.S)
        for destination in re.findall(r"(?<!!)\[[^\]]+\]\(([^)]+)\)", link_text):
            if re.match(r"[a-zA-Z][a-zA-Z0-9+.-]*:", destination) or destination.startswith("#"):
                continue
            local = destination.split("#", 1)[0]
            if local and not (path.parent / local).is_file():
                failures.append(f"Broken local file link: {path.name} -> {destination}")
    python_files = list(ROOT.rglob("*.py"))
    for path in python_files:
        try:
            ast.parse(path.read_text(encoding="utf-8"))
        except SyntaxError as error:
            failures.append(f"Invalid Python file {path.name}: {error}")
    result = {
        "lesson_word_counts": counts,
        "length_method": "Python len(text.split()); whitespace words; not model tokens",
        "python_blocks_syntax_checked": block_count,
        "python_files_syntax_checked": len(python_files),
        "failures": failures,
    }
    print(json.dumps(result, indent=2))
    if failures:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
