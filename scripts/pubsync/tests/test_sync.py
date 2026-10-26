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
    path = repo / "data/pub_coda_flad.yml"
    data = store.load(path)
    items = data["years"][0]["items"]
    for i in [i for i, it in enumerate(items) if it["title"] in titles][::-1]:
        del items[i]
    store.dump(data, path)


def run(repo, **kw):
    kw.setdefault("fetch", make_fetch())
    kw.setdefault("only", ONLY)
    kw.setdefault("fetch_bytes", fake_bytes)
    return sync.run(repo, **kw)


def test_flad_backfills_missing_months_in_order(tmp_repo):
    _drop_flad_items(tmp_repo, FLAD_NEW)
    run(tmp_repo)
    flad = store.load(tmp_repo / "data/pub_coda_flad.yml")
    items = flad["years"][0]["items"]
    assert [i["title"] for i in items[:4]] == FLAD_NEW + [
        "All-causes delay to air transport in Europe for June 2026"]
    assert "image" not in items[0]
    assert list(items[0]) == ["title", "date", "description", "url", "external"]


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
    path = repo / "data/pub_eao.yml"
    data = store.load(path)
    del data["years"][0]["items"][0]
    store.dump(data, path)
    return data


def test_eao_adds_item_with_image(tmp_repo):
    _eao_missing_one(tmp_repo)
    results = run(tmp_repo)
    r = next(r for r in results if r.key == "pub_eao")
    assert len(r.added) == 1
    item = r.added[0].item
    assert item["image"].startswith("/images/auto/pub_eao/")
    assert (tmp_repo / "static" / item["image"].lstrip("/")).read_bytes() == b"jpg"


def test_image_download_failure_adds_item_without_image(tmp_repo):
    _eao_missing_one(tmp_repo)

    def boom(url):
        raise OSError("down")

    r = next(r for r in run(tmp_repo, fetch_bytes=boom) if r.key == "pub_eao")
    assert len(r.added) == 1 and "image" not in r.added[0].item
    items = store.load(tmp_repo / "data/pub_eao.yml")["years"][0]["items"]
    assert "image" not in items[0]


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
