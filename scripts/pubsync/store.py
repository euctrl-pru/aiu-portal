"""Round-trip YAML store for data/pub_*.yml files (preserves comments and layout)."""
from pathlib import Path

from ruamel.yaml import YAML
from ruamel.yaml.comments import CommentedMap, CommentedSeq
from ruamel.yaml.scalarstring import DoubleQuotedScalarString


def _yaml() -> YAML:
    y = YAML()
    y.preserve_quotes = True
    y.indent(mapping=2, sequence=4, offset=2)
    y.width = 4096
    return y


def load(path: Path) -> CommentedMap:
    with open(path, encoding="utf-8") as f:
        return _yaml().load(f)


def dump(data, path: Path) -> None:
    with open(path, "w", encoding="utf-8") as f:
        _yaml().dump(data, f)


def _normalize(url: str) -> str:
    return url  # Task 2 replaces this with eurocontrol.normalize_url


def known_urls(data) -> set[str]:
    return {
        _normalize(str(item["url"]))
        for group in data["years"]
        for item in group["items"]
        if item.get("url")
    }


def _quoted(item: dict) -> CommentedMap:
    out = CommentedMap()
    for k, v in item.items():
        out[k] = DoubleQuotedScalarString(v) if isinstance(v, str) else v
    return out


def insert_item(data, year: int, item: dict) -> None:
    new = _quoted(item)
    years = data["years"]
    for group in years:
        if group["year"] == year:
            group["items"].insert(0, new)
            return
    group = CommentedMap()
    group["year"] = year
    group["items"] = CommentedSeq([new])
    pos = len(years)
    for i, g in enumerate(years):
        if g["year"] < year:
            pos = i
            break
    years.insert(pos, group)
