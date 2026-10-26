from datetime import date
from pathlib import Path

import pytest
import requests

from scripts.pubsync import eurocontrol as ec

FIXTURES = Path(__file__).parent / "fixtures"
URL_W41 = "https://www.eurocontrol.int/publication/eurocontrol-european-aviation-overview-2026-week-41"


def fixture(name):
    return (FIXTURES / name).read_text(encoding="utf-8")


def test_parse_listing_eao():
    entries = ec.parse_listing(fixture("listing_product_1249.html"))
    assert len(entries) == 12
    assert entries[0] == ec.ListingEntry(URL_W41, "EUROCONTROL European Aviation Overview 2026 - Week 41")


@pytest.mark.parametrize("name", ["listing_product_805.html", "listing_product_801.html"])
def test_parse_listing_other_products(name):
    entries = ec.parse_listing(fixture(name))
    assert entries and len({e.url for e in entries}) == len(entries)
    assert all(e.url.startswith("https://www.eurocontrol.int/publication/") for e in entries)


def test_parse_listing_empty_raises():
    with pytest.raises(ec.ListingParseError):
        ec.parse_listing("<html><body>No results</body></html>")


def test_parse_listing_dedupes_and_skips_empty_text():
    html = ('<a href="/publication/a">A</a><a href="/publication/a?x=1">A again</a>'
            '<a href="/publication/b"> </a><a href="/other">O</a>')
    assert ec.parse_listing(html) == [ec.ListingEntry("https://www.eurocontrol.int/publication/a", "A")]


def test_parse_publication_eao():
    p = ec.parse_publication(fixture("pub_eao_2026_w41.html"), URL_W41)
    assert p.published == date(2026, 10, 15)
    assert p.image_url.startswith("https://www.eurocontrol.int/sites/default/files/")
    assert "&amp;" not in p.image_url
    assert p.description.startswith("EUROCONTROL's European Aviation Overview")
    assert p.url == URL_W41


def test_parse_publication_flad():
    p = ec.parse_publication(fixture("pub_flad_sep_2026.html"), "u")
    assert p.published.year == 2026
    assert p.title


def test_publication_date_uses_brussels_time():
    html = '<time datetime="2026-10-14T23:30:00Z" class="datetime">x</time>'
    assert ec.parse_publication(html, "u").published == date(2026, 10, 15)


def test_publication_without_og_tags():
    p = ec.parse_publication('<time datetime="2026-01-05T12:00:00Z" class="datetime">x</time>', "u")
    assert p.description is None and p.image_url is None


@pytest.mark.parametrize("raw", [
    "/publication/foo", "http://www.eurocontrol.int/publication/foo",
    "https://www.eurocontrol.int/publication/foo/", "https://www.eurocontrol.int/publication/foo?x=1#y"])
def test_normalize_url_variants(raw):
    assert ec.normalize_url(raw) == "https://www.eurocontrol.int/publication/foo"


def test_normalize_leaves_site_paths():
    assert ec.normalize_url("/publications/prc/news/2020_10_15_pi_safety") == "/publications/prc/news/2020_10_15_pi_safety"


def test_normalize_leaves_other_hosts():
    assert ec.normalize_url("https://example.org/a/") == "https://example.org/a/"


def test_listing_url():
    assert ec.listing_url("product:805") == "https://www.eurocontrol.int/library/search?f%5B0%5D=product%3A805"
    assert ec.listing_url("keywords:PRC Observer") == "https://www.eurocontrol.int/library/search?keywords=PRC+Observer"


def test_format_date():
    assert ec.format_date(date(2026, 10, 2)) == "2 October 2026"


def _resp(content_type):
    r = requests.Response()
    r.status_code = 200
    r._content = b"data"
    r.headers["Content-Type"] = content_type
    return r


def test_fetch_bytes_accepts_images(monkeypatch):
    monkeypatch.setattr(ec.requests, "get", lambda *a, **k: _resp("image/jpeg"))
    monkeypatch.setattr(ec, "MIN_INTERVAL", 0)
    assert ec.fetch_bytes("https://www.eurocontrol.int/x.jpg") == b"data"


def test_fetch_bytes_rejects_non_images(monkeypatch):
    monkeypatch.setattr(ec.requests, "get", lambda *a, **k: _resp("text/html; charset=utf-8"))
    monkeypatch.setattr(ec, "MIN_INTERVAL", 0)
    with pytest.raises(ValueError):
        ec.fetch_bytes("https://www.eurocontrol.int/x.jpg")
