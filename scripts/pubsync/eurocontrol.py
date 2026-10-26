"""Fetch and parse eurocontrol.int library listings and publication pages."""
import datetime
import time
from dataclasses import dataclass
from urllib.parse import quote_plus, urlsplit
from zoneinfo import ZoneInfo

import requests
from bs4 import BeautifulSoup

BASE = "https://www.eurocontrol.int"
USER_AGENT = "aiu-portal-pubsync (+https://ansperformance.eu)"
TIMEOUT = 30
ATTEMPTS = 3
BACKOFF = 5
MIN_INTERVAL = 1.0
BRUSSELS = ZoneInfo("Europe/Brussels")

_last_request = 0.0


class ListingParseError(Exception):
    pass


@dataclass(frozen=True)
class ListingEntry:
    url: str
    title: str


@dataclass(frozen=True)
class Publication:
    url: str
    title: str
    published: datetime.date
    description: str | None
    image_url: str | None


def normalize_url(url: str) -> str:
    """Canonical absolute eurocontrol.int URL; anything else is returned unchanged."""
    if url.startswith("/publication/"):
        url = BASE + url
    parts = urlsplit(url)
    if parts.hostname != "www.eurocontrol.int":
        return url
    return f"{BASE}{parts.path.rstrip('/')}"


def _get(url: str) -> requests.Response:
    """GET with the shared User-Agent, rate limit and retry policy."""
    global _last_request
    for attempt in range(1, ATTEMPTS + 1):
        wait = MIN_INTERVAL - (time.monotonic() - _last_request)
        if wait > 0:
            time.sleep(wait)
        _last_request = time.monotonic()
        try:
            resp = requests.get(url, headers={"User-Agent": USER_AGENT}, timeout=TIMEOUT)
            resp.raise_for_status()
            return resp
        except requests.RequestException:
            if attempt == ATTEMPTS:
                raise
            time.sleep(BACKOFF)
    raise AssertionError("unreachable")


def fetch(url: str) -> str:
    return _get(url).text


def fetch_bytes(url: str) -> bytes:
    """Download an image; anything not served as image/* is rejected."""
    resp = _get(url)
    content_type = resp.headers.get("Content-Type", "")
    if not content_type.lower().startswith("image/"):
        raise ValueError(f"expected an image from {url}, got {content_type!r}")
    return resp.content


def listing_url(source: str) -> str:
    kind, _, value = source.partition(":")
    if kind == "product":
        return f"{BASE}/library/search?f%5B0%5D=product%3A{value}"
    if kind == "keywords":
        return f"{BASE}/library/search?keywords={quote_plus(value)}"
    raise ValueError(f"unknown source: {source!r}")


def parse_listing(html: str) -> list[ListingEntry]:
    soup = BeautifulSoup(html, "html.parser")
    seen: set[str] = set()
    entries: list[ListingEntry] = []
    for a in soup.find_all("a", href=True):
        if not a["href"].startswith("/publication/"):
            continue
        title = a.get_text(strip=True)
        url = normalize_url(a["href"])
        if not title or url in seen:
            continue
        seen.add(url)
        entries.append(ListingEntry(url, title))
    if not entries:
        raise ListingParseError("no publication links found in listing")
    return entries


def _meta(soup: BeautifulSoup, prop: str) -> str | None:
    tag = soup.find("meta", attrs={"property": prop})
    content = tag.get("content", "").strip() if tag else ""
    return content or None


def parse_publication(html: str, url: str) -> Publication:
    soup = BeautifulSoup(html, "html.parser")
    time_tag = soup.find("time", class_="datetime", attrs={"datetime": True})
    if time_tag is None:
        raise ValueError(f"no publication date found in {url}")
    stamp = datetime.datetime.fromisoformat(time_tag["datetime"].replace("Z", "+00:00"))
    return Publication(
        url=url,
        title=_meta(soup, "og:title") or "",
        published=stamp.astimezone(BRUSSELS).date(),
        description=_meta(soup, "og:description"),
        image_url=_meta(soup, "og:image"),
    )


def format_date(d: datetime.date) -> str:
    return f"{d.day} {d:%B %Y}"
