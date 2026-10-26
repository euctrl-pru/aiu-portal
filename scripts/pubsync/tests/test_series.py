from datetime import date
from pathlib import Path

import pytest

from scripts.pubsync import store
from scripts.pubsync.eurocontrol import ListingEntry
from scripts.pubsync.series import SERIES, group_year, render_title

DATA = Path(__file__).resolve().parents[3] / "data"

CASES = [
    ("pub_eao", "EUROCONTROL European Aviation Overview 2026 - Week 43", "EUROCONTROL European Aviation Overview 2026 - Week 43", 2026),
    ("pub_coda_flad", "All-causes delay to air transport in Europe for September 2026", "All-causes delay to air transport in Europe for September 2026", 2026),
    ("pub_coda_digest", "All-causes delays to air transport in Europe - Annual 2025", "All-Causes Delays to Air Transport in Europe - Annual 2025", 2025),
    ("pub_coda_taxi", "Taxi times - Summer 2026", "Taxi times - Summer 2026", 2026),
    ("pub_datasnap", "EUROCONTROL Data Snapshot #62 on winter traffic", "Data Snapshot #62 - Winter traffic", 2026),
    ("pub_think", "EUROCONTROL Think Paper #23 - Foo", "Think Paper #23 - Foo", 2026),
    ("pub_trends", "Some new topic", "Aviation Trends #13 - Some new topic", 2026),
    ("pub_ace", "Air traffic management cost-effectiveness (ACE) benchmarking report (2027 edition)", "ATM Cost Effectiveness (ACE) Report 2027 Edition", 2027),
    ("pub_prr", "Performance Review Report (PRR) 2026", "Performance Review Report 2026", 2026),
    # Wording seen on the live listing (2026-10-26)
    ("pub_coda_digest", "All-Causes Delays to Air Transport in Europe - Annual 2024", "All-Causes Delays to Air Transport in Europe - Annual 2024", 2024),
    ("pub_coda_digest", "All-Causes Delays to Air Transport in Europe - Quarter 3 2023", "All-Causes Delays to Air Transport in Europe - Quarter 3 2023", 2023),
    ("pub_flash", "EUROCONTROL Flash Briefing 2026 - Week 35", "EUROCONTROL Flash Briefing 2026 - Week 35", 2026),
    ("pub_flash", "EUROCONTROL Special Summer 2026 Flash Briefing", "EUROCONTROL Special Summer 2026 Flash Briefing", 2026),
]


def _existing(key):
    if key == "pub_trends":  # fixed so the test survives the bot adding new issues
        return ["Aviation Trends #12 - x", "Aviation Trends #3 - y"]
    return [i["title"] for g in store.load(DATA / f"{key}.yml")["years"] for i in g["items"]]


@pytest.mark.parametrize("key,site_title,expected_title,expected_year", CASES)
def test_render_title_and_year(key, site_title, expected_title, expected_year):
    # digest has two rows (annual/quarterly): exactly one must match
    rendered = [(s, render_title(s, ListingEntry("u", site_title), _existing(key)))
                for s in SERIES if s.key == key]
    matches = [(s, t) for s, t in rendered if t is not None]
    assert len(matches) == 1
    s, title = matches[0]
    assert title == expected_title
    assert group_year(s, title, date(2026, 11, 1)) == expected_year


def test_digest_descriptions_differ_for_annual_and_quarterly():
    descs = {s.include: s.description for s in SERIES if s.key == "pub_coda_digest"}
    assert len(descs) == 2
    assert any(d.startswith("Annual") for d in descs.values())
    assert any(d.startswith("Quarterly") for d in descs.values())


@pytest.mark.parametrize("key,site_title", [
    ("pub_ace", "ATM Cost-Effectiveness (ACE): First look at ANSPs' 2025 data"),
    ("pub_ace", "High-level Summary Report on preliminary ACE 2024 data"),
    ("pub_prr", "Review of the most penalising Area Control Centers in 2025"),
    ("pub_coda_flad", "All-causes delays to air transport in Europe - Annual 2025"),
])
def test_unrelated_titles_in_shared_facets_are_rejected(key, site_title):
    s = next(s for s in SERIES if s.key == key)
    assert render_title(s, ListingEntry("u", site_title), []) is None
