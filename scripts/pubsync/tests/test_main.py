from scripts.pubsync.__main__ import _summary
from scripts.pubsync.sync import NewItem, SeriesResult


def test_summary_lists_image_notes():
    item = {"title": "T", "date": "1 October 2026"}
    results = [
        SeriesResult("pub_flash", [NewItem("pub_flash", 2026, item, None)],
                     notes=["T: no image (OSError: down)"]),
        SeriesResult("pub_eao"),
    ]
    text = _summary(results, [], None)
    assert "- Added `pub_flash`: T (1 October 2026)" in text
    assert "### Notes\n\n- `pub_flash`: T: no image (OSError: down)\n" in text


def test_summary_without_notes_has_no_notes_section():
    assert "### Notes" not in _summary([SeriesResult("pub_eao")], [], None)
