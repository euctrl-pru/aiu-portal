"""Sync engine: find publications missing from data/pub_*.yml and add them."""
from collections.abc import Callable, Sequence
from dataclasses import dataclass, field
from pathlib import Path

from . import eurocontrol, store
from .series import SERIES, Series, group_year, render_title

REPO_ROOT = Path(__file__).resolve().parents[2]
STATFOR_FILES = ["pub_statfor_2year", "pub_statfor_forecast7", "pub_statfor_outlook", "pub_statfor_update"]
STATFOR_SOURCE = "product:801"


@dataclass
class NewItem:
    series_key: str
    year: int
    item: dict
    image_url: str | None
    image_path: str | None  # repo-relative path the image is saved to


@dataclass
class SeriesResult:
    key: str
    added: list[NewItem] = field(default_factory=list)
    error: str | None = None


def _slug(url: str) -> str:
    return url.rstrip("/").rsplit("/", 1)[-1]


def find_new(series: Series | Sequence[Series], data, fetch: Callable[[str], str],
             max_new: int = 5) -> SeriesResult:
    """New publications for one data file, oldest first.

    `series` may be several rows sharing a key; for each listing entry every
    row is tried and the first whose include pattern matches wins.
    """
    rows = [series] if isinstance(series, Series) else list(series)
    key = rows[0].key
    known = store.known_urls(data)
    titles = [str(i["title"]) for g in data["years"] for i in g["items"]]

    found: list[tuple[Series, str, eurocontrol.ListingEntry]] = []
    seen: set[str] = set()
    for source in dict.fromkeys(r.source for r in rows):
        for entry in eurocontrol.parse_listing(fetch(eurocontrol.listing_url(source))):
            if entry.url in known or entry.url in seen:
                continue
            for row in rows:
                title = render_title(row, entry, titles)
                if title is not None:
                    seen.add(entry.url)
                    found.append((row, title, entry))
                    break
    if len(found) > max_new:
        return SeriesResult(key, [], f"{len(found)} new items exceeds max_new={max_new}; skipped")

    added: list[NewItem] = []
    for row, _, entry in reversed(found):  # oldest first (listing is newest first)
        # Recompute so numbered titles (#n) count items added earlier in this run.
        title = render_title(row, entry, titles)
        pub = eurocontrol.parse_publication(fetch(entry.url), entry.url)
        item: dict = {"title": title, "date": eurocontrol.format_date(pub.published)}
        description = row.description or pub.description
        if description:
            item["description"] = description
        item["url"] = entry.url
        image_url = pub.image_url if row.images else None
        image_path = None
        if image_url:
            image_path = f"static/images/auto/{key}/{_slug(entry.url)}.jpg"
            item["image"] = f"/images/auto/{key}/{_slug(entry.url)}.jpg"
        item["external"] = True
        titles.append(title)
        added.append(NewItem(key, group_year(row, title, pub.published), item, image_url, image_path))
    return SeriesResult(key, added)


def _memoized(fetch: Callable[[str], str]) -> Callable[[str], str]:
    cache: dict[str, str] = {}

    def cached(url: str) -> str:
        if url not in cache:
            cache[url] = fetch(url)
        return cache[url]

    return cached


def run(repo_root: Path, fetch=eurocontrol.fetch, dry_run: bool = False, max_new: int = 5,
        only: set[str] | None = None, fetch_bytes=eurocontrol.fetch_bytes) -> list[SeriesResult]:
    fetch = _memoized(fetch)  # each listing is fetched at most once per run
    groups: dict[str, list[Series]] = {}
    for s in SERIES:
        if only is None or s.key in only:
            groups.setdefault(s.key, []).append(s)

    results: list[SeriesResult] = []
    for key, rows in groups.items():
        try:
            path = repo_root / "data" / f"{key}.yml"
            data = store.load(path)
            result = find_new(rows, data, fetch, max_new)
            if result.added and not dry_run:
                images: dict[Path, bytes] = {}
                for new in result.added:
                    if new.image_url:
                        try:
                            images[repo_root / new.image_path] = fetch_bytes(new.image_url)
                        except Exception:
                            new.item.pop("image", None)
                            new.image_path = None
                    store.insert_item(data, new.year, new.item)
                store.dump(data, path)
                # Only after the YAML is saved, so a failed series leaves no orphan images.
                for dest, blob in images.items():
                    dest.parent.mkdir(parents=True, exist_ok=True)
                    dest.write_bytes(blob)
        except Exception as e:
            result = SeriesResult(key, [], f"{type(e).__name__}: {e}")
        results.append(result)
    return results


def report_unmatched(fetch: Callable[[str], str], repo_root: Path = REPO_ROOT) -> list[eurocontrol.ListingEntry]:
    """STATFOR listing entries whose URL is in none of the pub_statfor_*.yml files."""
    known: set[str] = set()
    for name in STATFOR_FILES:
        known |= store.known_urls(store.load(repo_root / "data" / f"{name}.yml"))
    entries = eurocontrol.parse_listing(fetch(eurocontrol.listing_url(STATFOR_SOURCE)))
    return [e for e in entries if e.url not in known]
