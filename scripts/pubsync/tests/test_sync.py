import difflib
import shutil
from pathlib import Path

import pytest

from scripts.pubsync import eurocontrol, store, sync

REPO = Path(__file__).resolve().parents[3]
FIX = Path(__file__).parent / "fixtures"
ONLY = {"pub_coda_flad", "pub_eao"}
FLAD_NEW = [
    "All-causes delay to air transport in Europe for September 2026",
    "All-causes delay to air transport in Europe for August 2026",
    "All-causes delay to air transport in Europe for July 2026",
]


def _fx(name):
    return (FIX / name).read_text(encoding="utf-8")


LISTINGS = {
    eurocontrol.listing_url("product:1249"): "listing_product_1249.html",
    eurocontrol.listing_url("product:805"): "listing_product_805.html",
    eurocontrol.listing_url("product:801"): "listing_product_801.html",
}


def make_fetch(overrides=None, calls=None):
    overrides = overrides or {}

    def fetch(url):
        if calls is not None:
            calls.append(url)
        if url in overrides:
            return overrides[url]
        if url in LISTINGS:
            return _fx(LISTINGS[url])
        if "/publication/" in url:
            return _fx("pub_flad_sep_2026.html" if "all-causes" in url else "pub_eao_2026_w41.html")
        raise AssertionError(f"unexpected fetch {url}")

    return fetch


def fake_bytes(url):
    return b"jpg"


@pytest.fixture
def tmp_repo(tmp_path):
    shutil.copytree(REPO / "data", tmp_path / "data")
    (tmp_path / "static").mkdir()
    return tmp_path


def _drop_flad_items(repo, titles):
    """Textually delete the 5-line item blocks with these titles (file stays hand-written)."""
    path = repo / "data/pub_coda_flad.yml"
    lines = path.read_text().splitlines(keepends=True)
    out, skipping = [], False
    for line in lines:
        if line.startswith("      - title: "):
            skipping = any(f'"{t}"' in line for t in titles)
        elif not line.startswith("        "):
            skipping = False
        if not skipping:
            out.append(line)
    assert len(out) == len(lines) - 5 * len(titles)
    path.write_text("".join(out))


def _flad_titles(repo):
    data = store.load(repo / "data/pub_coda_flad.yml")
    return [i["title"] for g in data["years"] for i in g["items"]]


def run(repo, **kw):
    kw.setdefault("fetch", make_fetch())
    kw.setdefault("only", ONLY)
    kw.setdefault("fetch_bytes", fake_bytes)
    return sync.run(repo, **kw)


def test_flad_backfills_missing_months_in_order(tmp_repo):
    _drop_flad_items(tmp_repo, FLAD_NEW)
    run(tmp_repo)
    titles = _flad_titles(tmp_repo)
    june = "All-causes delay to air transport in Europe for June 2026"
    pos = [titles.index(t) for t in FLAD_NEW + [june]]
    assert pos == sorted(pos) and len(set(pos)) == 4
    flad = store.load(tmp_repo / "data/pub_coda_flad.yml")
    added = next(i for g in flad["years"] for i in g["items"] if i["title"] == FLAD_NEW[0])
    assert "image" not in added
    assert list(added) == ["title", "date", "description", "url", "external"]


def test_second_run_adds_nothing(tmp_repo):
    _drop_flad_items(tmp_repo, FLAD_NEW)
    run(tmp_repo)
    before = (tmp_repo / "data/pub_coda_flad.yml").read_text()
    results = run(tmp_repo)
    assert all(not r.added for r in results)
    assert (tmp_repo / "data/pub_coda_flad.yml").read_text() == before


def test_too_many_new_skips_series(tmp_repo):
    (tmp_repo / "data/pub_coda_flad.yml").write_text("years: []\n")
    r = next(r for r in run(tmp_repo) if r.key == "pub_coda_flad")
    assert r.added == [] and "max_new" in r.error
    assert (tmp_repo / "data/pub_coda_flad.yml").read_text() == "years: []\n"


def test_listing_failure_isolated(tmp_repo):
    broken = make_fetch({eurocontrol.listing_url("product:805"): "<html></html>"})
    results = {r.key: r for r in run(tmp_repo, fetch=broken)}
    assert results["pub_coda_flad"].error
    assert results["pub_eao"].error is None


def _eao_missing_one(repo):
    """Remove the item for the newest EAO in the fixture listing (by URL, wherever it sits)."""
    path = repo / "data/pub_eao.yml"
    newest = eurocontrol.parse_listing(_fx("listing_product_1249.html"))[0].url
    data = store.load(path)
    for g in data["years"]:
        g["items"][:] = [i for i in g["items"] if eurocontrol.normalize_url(str(i["url"])) != newest]
    store.dump(data, path)
    return newest


def _eao_items(repo):
    return [i for g in store.load(repo / "data/pub_eao.yml")["years"] for i in g["items"]]


def test_eao_adds_item_with_image(tmp_repo):
    newest = _eao_missing_one(tmp_repo)
    results = run(tmp_repo)
    r = next(r for r in results if r.key == "pub_eao")
    assert len(r.added) == 1
    item = r.added[0].item
    assert item["url"] == newest
    assert item["image"].startswith("/images/auto/pub_eao/")
    assert (tmp_repo / "static" / item["image"].lstrip("/")).read_bytes() == b"jpg"


def test_image_download_failure_adds_item_without_image(tmp_repo):
    _eao_missing_one(tmp_repo)

    def boom(url):
        raise OSError("down")

    r = next(r for r in run(tmp_repo, fetch_bytes=boom) if r.key == "pub_eao")
    assert len(r.added) == 1 and "image" not in r.added[0].item
    added = next(i for i in _eao_items(tmp_repo) if i["url"] == r.added[0].item["url"])
    assert "image" not in added


def test_missing_og_tags_still_adds(tmp_repo):
    _eao_missing_one(tmp_repo)
    bare = make_fetch()

    def fetch(url):
        html = bare(url)
        return "\n".join(l for l in html.splitlines() if "og:" not in l) if "/publication/" in url else html

    r = next(r for r in run(tmp_repo, fetch=fetch) if r.key == "pub_eao")
    assert len(r.added) == 1
    item = r.added[0].item
    assert item["description"] == "Biweekly overview of European aviation activity."
    assert "image" not in item


def test_dry_run_writes_nothing(tmp_repo):
    _drop_flad_items(tmp_repo, FLAD_NEW)
    before = {p: p.read_bytes() for p in (tmp_repo / "data").glob("*.yml")}
    results = run(tmp_repo, dry_run=True)
    assert [n.item["title"] for n in next(r for r in results if r.key == "pub_coda_flad").added] == FLAD_NEW[::-1]
    assert {p: p.read_bytes() for p in (tmp_repo / "data").glob("*.yml")} == before
    assert not list((tmp_repo / "static").rglob("*"))


def test_each_listing_fetched_once(tmp_repo):
    calls = []
    sync.run(tmp_repo, fetch=make_fetch(calls=calls), only={"pub_coda_flad", "pub_coda_digest"},
             fetch_bytes=fake_bytes)
    listing = eurocontrol.listing_url("product:805")
    assert calls.count(listing) == 1


def test_unmatched_statfor_reported():
    unmatched = sync.report_unmatched(make_fetch(), REPO)
    assert "https://www.eurocontrol.int/publication/eurocontrol-forecast-update-2026-2032" in {
        e.url for e in unmatched}


def _assert_only_additions(before: str, after: str):
    diff = list(difflib.unified_diff(before.splitlines(), after.splitlines(), lineterm="", n=0))
    body = [l for l in diff if not l.startswith(("---", "+++", "@@"))]
    assert body and all(l.startswith("+") for l in body), "\n".join(diff)


def test_flad_insert_only_adds_lines(tmp_repo):
    path = tmp_repo / "data/pub_coda_flad.yml"
    _drop_flad_items(tmp_repo, FLAD_NEW)
    before = path.read_text()
    run(tmp_repo)
    _assert_only_additions(before, path.read_text())


def test_flash_insert_only_adds_lines(tmp_repo):
    path = tmp_repo / "data/pub_flash.yml"
    before = path.read_text()
    url = "/publication/eurocontrol-flash-briefing-2026-week-99"
    listing = f'<html><a href="{url}">EUROCONTROL Flash Briefing 2026 - Week 99</a></html>'
    fetch = make_fetch({eurocontrol.listing_url("product:1245"): listing})
    results = run(tmp_repo, fetch=fetch, only={"pub_flash"})
    assert len(results[0].added) == 1
    after = path.read_text()
    _assert_only_additions(before, after)
    assert "Flash Briefing 2026 - Week 99" in after


def test_images_not_written_when_series_fails_after_download(tmp_repo, monkeypatch):
    _eao_missing_one(tmp_repo)

    def failing_dump(data, path):
        raise OSError("disk full")

    monkeypatch.setattr(store, "dump", failing_dump)
    r = next(r for r in run(tmp_repo) if r.key == "pub_eao")
    assert r.error and not r.added
    assert not list((tmp_repo / "static").rglob("*.jpg"))


def _flash_repo_run(tmp_repo, href, page_edit=None, fetch_bytes=fake_bytes):
    listing = f'<html><a href="{href}">EUROCONTROL Flash Briefing 2026 - Week 99</a></html>'
    base = make_fetch({eurocontrol.listing_url("product:1245"): listing})

    def fetch(url):
        html = base(url)
        return page_edit(html) if page_edit and "/publication/" in url else html

    return run(tmp_repo, fetch=fetch, only={"pub_flash"}, fetch_bytes=fetch_bytes)[0]


def test_scraped_description_is_html_escaped(tmp_repo):
    def edit(html):
        import re
        return re.sub(r'(<meta property="og:description" content=")[^"]*"',
                      r'\1&lt;script&gt;alert(1)&lt;/script&gt; R&amp;D"', html)

    r = _flash_repo_run(tmp_repo, "/publication/flash-99", edit)
    assert r.added[0].item["description"] == "&lt;script&gt;alert(1)&lt;/script&gt; R&amp;D"
    stored = (tmp_repo / "data/pub_flash.yml").read_text()
    assert "&lt;script&gt;alert(1)&lt;/script&gt; R&amp;D" in stored


def test_off_site_image_url_is_skipped(tmp_repo):
    called = []
    edit = lambda h: h.replace("https://www.eurocontrol.int/sites", "https://evil.example/sites")  # noqa: E731
    r = _flash_repo_run(tmp_repo, "/publication/flash-99", edit,
                        fetch_bytes=lambda u: called.append(u) or b"x")
    assert len(r.added) == 1 and "image" not in r.added[0].item and not called


@pytest.mark.parametrize("slug", ["..", "Foo%2F..", "UPPER", ".hidden", "a" * 200])
def test_unsafe_slug_skips_image(tmp_repo, slug):
    called = []
    r = _flash_repo_run(tmp_repo, f"/publication/{slug}",
                        fetch_bytes=lambda u: called.append(u) or b"x")
    assert r.error is None and len(r.added) == 1
    assert "image" not in r.added[0].item and not called
    assert not list((tmp_repo / "static").rglob("*.jpg"))


def test_destination_outside_static_auto_is_refused(tmp_repo, monkeypatch):
    monkeypatch.setattr(sync, "SLUG_RE", __import__("re").compile(r".+"))  # bypass the slug filter
    monkeypatch.setattr(sync, "_slug", lambda url: "../../evil")
    called = []
    r = _flash_repo_run(tmp_repo, "/publication/flash-99",
                        fetch_bytes=lambda u: called.append(u) or b"x")
    assert len(r.added) == 1 and "image" not in r.added[0].item
    assert not called and not list(tmp_repo.rglob("*.jpg"))
