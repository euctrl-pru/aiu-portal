"""Which publication series are automated, and how listing titles map to data-file titles."""
import re
from dataclasses import dataclass
from datetime import date
from typing import Literal

from .eurocontrol import ListingEntry


@dataclass(frozen=True)
class Series:
    key: str
    source: str
    include: str
    title: str
    description: str | None
    images: bool
    year_from: Literal["title", "published"]


def _s(key, source, include, title, description, images=True, year_from="published"):
    return Series(key, source, include, title, description, images, year_from)


OBSERVER = r"PRC Observer #\d+ - .+"

SERIES: list[Series] = [
    _s("pub_eao", "product:1249", r"EUROCONTROL European Aviation Overview \d{4} - Week \d+",
       "{0}", "Biweekly overview of European aviation activity.", year_from="title"),
    _s("pub_coda_flad", "product:805", r"All-causes delay to air transport in Europe for (\w+) (\d{4})",
       "{0}", "Monthly brief on all-causes delay to air transport in Europe.",
       images=False, year_from="title"),
    _s("pub_coda_digest", "product:805",
       r"All-causes delays to air transport in Europe - (Annual) (\d{4})",
       "All-Causes Delays to Air Transport in Europe - {1} {2}",
       "Annual report on all-causes delays to air transport in Europe.", year_from="title"),
    _s("pub_coda_digest", "product:805",
       r"All-causes delays to air transport in Europe - (Quarter \d) (\d{4})",
       "All-Causes Delays to Air Transport in Europe - {1} {2}",
       "Quarterly report on all-causes delays to air transport in Europe.", year_from="title"),
    _s("pub_coda_taxi", "product:812", r"Taxi times - (Summer \d{4}|Winter \d{4}-\d{4})",
       "{0}", "Taxi time statistics at European airports.", year_from="title"),
    _s("pub_datasnap", "product:1136", r"EUROCONTROL Data Snapshot #(\d+) on (.+)",
       "Data Snapshot #{1} - {2}", None),
    _s("pub_flash", "product:1245", r"EUROCONTROL .*Flash Briefing.*", "{0}", None),
    _s("pub_think", "product:1002", r"EUROCONTROL Think Paper #\d+ - .+", "{site}", None),
    _s("pub_trends", "product:1197", r".+", "Aviation Trends #{n} - {site}", None),
    _s("pub_ace", "product:984",
       r"Air traffic management cost-effectiveness \(ACE\) benchmarking report \((\d{4}) edition\)",
       "ATM Cost Effectiveness (ACE) Report {1} Edition", None, year_from="title"),
    _s("pub_prr", "product:983", r"Performance Review Report \(PRR\) (\d{4})",
       "Performance Review Report {1}", None, year_from="title"),
    _s("pub_pi", "product:985", r"PRC Performance Insight #\d+ - .+", "{0}", None),
    _s("pub_pi", "keywords:PRC Observer", OBSERVER, "{0}", None),
    _s("pub_observer", "keywords:PRC Observer", OBSERVER, "{0}", None),
]


def render_title(series: Series, entry: ListingEntry, existing_titles: list[str]) -> str | None:
    """Return the data-file title for a listing entry, or None if it is not part of the series."""
    m = re.fullmatch(series.include, entry.title, re.IGNORECASE)
    if not m:
        return None
    # Captured groups are free text from the site; capitalise their first letter.
    groups = [g[:1].upper() + g[1:] for g in m.groups("")]
    numbers = [int(n.group(1)) for t in existing_titles if (n := re.search(r"#(\d+)", t))]
    return series.title.format(
        entry.title, *groups,
        site=entry.title.removeprefix("EUROCONTROL "),
        n=max(numbers, default=0) + 1,
    )


def group_year(series: Series, title: str, published: date) -> int:
    """Year of the data-file group a new item belongs to."""
    if series.year_from == "published":
        return published.year
    return int(re.findall(r"\d{4}", title)[-1])
