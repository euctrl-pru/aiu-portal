from datetime import date
from pathlib import Path

import pytest

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
    assert ec.listing_url("keywords:PRC Observer") == "https://www.eurocontrol.int/library/search?keywords=PRC+Observer&items_per_page=50"


def test_format_date():
    assert ec.format_date(date(2026, 10, 2)) == "2 October 2026"


class FakeResponse:
    def __init__(self, content_type="image/jpeg", body=b"data", location=None):
        self.headers = {"Content-Type": content_type}
        if location:
            self.headers["Location"] = location
        self.is_redirect = location is not None
        self._body = body

    def raise_for_status(self):
        pass

    def iter_content(self, size):
        for i in range(0, len(self._body), size):
            yield self._body[i:i + size]

    def close(self):
        pass


def _patch_get(monkeypatch, *responses):
    seen = []
    queue = list(responses)

    def get(url, **kwargs):
        seen.append((url, kwargs))
        return queue.pop(0)

    monkeypatch.setattr(ec.requests, "get", get)
    monkeypatch.setattr(ec, "MIN_INTERVAL", 0)
    return seen


IMG = "https://www.eurocontrol.int/sites/x.jpg"


def test_fetch_image_accepts_images(monkeypatch):
    seen = _patch_get(monkeypatch, FakeResponse())
    assert ec.fetch_image(IMG) == (b"data", ".jpg")
    assert seen[0][1]["allow_redirects"] is False


@pytest.mark.parametrize("content_type,ext", [
    ("image/jpeg", ".jpg"), ("image/png", ".png"), ("image/webp", ".webp"), ("image/gif", ".gif"),
    ("IMAGE/PNG; charset=binary", ".png")])
def test_fetch_image_extension_from_content_type(monkeypatch, content_type, ext):
    _patch_get(monkeypatch, FakeResponse(content_type))
    assert ec.fetch_image(IMG) == (b"data", ext)


@pytest.mark.parametrize("content_type", ["text/html; charset=utf-8", "image/svg+xml", "image/tiff", ""])
def test_fetch_image_rejects_other_types(monkeypatch, content_type):
    _patch_get(monkeypatch, FakeResponse(content_type))
    with pytest.raises(ValueError):
        ec.fetch_image(IMG)


@pytest.mark.parametrize("url", [
    "https://evil.example/x.jpg",
    "http://www.eurocontrol.int/x.jpg",
    "https://www.eurocontrol.int.evil.example/x.jpg",
])
def test_fetch_image_rejects_off_site_urls(monkeypatch, url):
    seen = _patch_get(monkeypatch)
    with pytest.raises(ValueError):
        ec.fetch_image(url)
    assert seen == []


def test_fetch_image_rejects_redirect_off_site(monkeypatch):
    seen = _patch_get(monkeypatch, FakeResponse(location="https://evil.example/x.jpg"))
    with pytest.raises(ValueError):
        ec.fetch_image(IMG)
    assert len(seen) == 1


def test_fetch_image_follows_on_site_redirect(monkeypatch):
    _patch_get(monkeypatch, FakeResponse(location="/other.jpg"), FakeResponse())
    assert ec.fetch_image(IMG) == (b"data", ".jpg")


def test_fetch_image_rejects_oversize_body(monkeypatch):
    monkeypatch.setattr(ec, "MAX_IMAGE_BYTES", 100)
    _patch_get(monkeypatch, FakeResponse(body=b"x" * 101))
    with pytest.raises(ValueError):
        ec.fetch_image(IMG)
