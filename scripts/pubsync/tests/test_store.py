from pathlib import Path
import shutil

import pytest

from scripts.pubsync import store

DATA = Path(__file__).resolve().parents[3] / "data"
FLAD = DATA / "pub_coda_flad.yml"


@pytest.mark.parametrize("path", sorted(DATA.glob("pub_*.yml")), ids=lambda p: p.name)
def test_roundtrip_is_byte_identical(path, tmp_path):
    out = tmp_path / path.name
    store.dump(store.load(path), out)
    assert out.read_text() == path.read_text()


def _flad_copy(tmp_path):
    p = tmp_path / "pub_coda_flad.yml"
    shutil.copy(FLAD, p)
    return p


def _item(title="All-causes delay to air transport in Europe for July 2026"):
    return {
        "title": title,
        "date": "21 August 2026",
        "description": "Monthly brief.",
        "url": "https://www.eurocontrol.int/publication/x",
        "external": True,
    }


def test_insert_into_existing_year_goes_first(tmp_path):
    data = store.load(_flad_copy(tmp_path))
    previous_first = data["years"][0]["items"][0]["title"]
    store.insert_item(data, 2026, _item())
    items = data["years"][0]["items"]
    assert items[0]["title"] == "All-causes delay to air transport in Europe for July 2026"
    assert items[1]["title"] == previous_first


def test_insert_new_year_group_sorted(tmp_path):
    data = store.load(_flad_copy(tmp_path))
    store.insert_item(data, 2027, _item("A"))
    assert data["years"][0]["year"] == 2027
    assert data["years"][0]["items"][0]["title"] == "A"
    store.insert_item(data, 2010, _item("B"))
    assert data["years"][-1]["year"] == 2010
    years = [g["year"] for g in data["years"]]
    assert years == sorted(years, reverse=True)


def test_inserted_item_is_double_quoted(tmp_path):
    p = _flad_copy(tmp_path)
    data = store.load(p)
    store.insert_item(data, 2026, _item("X"))
    store.dump(data, p)
    text = p.read_text()
    assert '      - title: "X"' in text
    assert '        external: true' in text


def test_known_urls_covers_all_groups():
    urls = store.known_urls(store.load(FLAD))
    assert "https://www.eurocontrol.int/publication/all-causes-delay-air-transport-europe-june-2026" in urls
    assert len(urls) >= 21  # the bot appends new entries over time
