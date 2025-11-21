"""
GarysGuide scraper with Popular Events detection.

This script fetches listings from https://www.garysguide.com/events,
extracts structured metadata for each event, and highlights events that
appear in the "Popular Events" section or carry special badges.

Usage examples:
    python scripts/garysguide_scraper.py --limit 20
    python scripts/garysguide_scraper.py --export data/events.json
    python scripts/garysguide_scraper.py --popular-only --export data/popular.json
"""

from __future__ import annotations

import argparse
import json
import logging
import time
from dataclasses import dataclass, field, asdict
from datetime import datetime, timedelta
from pathlib import Path
from typing import Dict, Iterable, List, Optional
from urllib.parse import urljoin

import requests
from bs4 import BeautifulSoup, Tag
from dateutil import parser as date_parser

BASE_URL = "https://www.garysguide.com"
EVENTS_PATH = "/events"
DEFAULT_FETCH_LIMIT = 50

LOGGER = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO, format="%(asctime)s | %(levelname)s | %(message)s")


@dataclass
class GarysGuideEvent:
    title: str
    link: str
    date_label: Optional[str] = None
    time_label: Optional[str] = None
    cost: Optional[str] = None
    location: Optional[str] = None
    short_description: Optional[str] = None
    badges: List[str] = field(default_factory=list)
    week_label: Optional[str] = None
    iso_datetime: Optional[str] = None
    register_link: Optional[str] = None
    long_description: Optional[str] = None
    source: str = "garysguide"
    is_popular: bool = False

    def tracker_metadata(self) -> Dict[str, str]:
        """Format metadata for downstream storage."""
        time_part = self.iso_datetime or (self.time_label or "")
        notes = self.long_description or self.short_description or ""
        if self.register_link and self.register_link != self.link:
            notes_suffix = f" (Original listing: {self.link})"
            notes = (notes or "") + notes_suffix
        return {
            "title": self.title,
            "time": time_part,
            "address": self.location or "",
            "notes": notes.strip(),
            "source": self.source,
            "is_popular": "true" if self.is_popular else "false",
        }

    def tracking_url(self) -> str:
        """Prefer the external registration link when available."""
        return self.register_link or self.link

    def to_dict(self) -> Dict[str, Optional[str]]:
        """Serialize event into a JSON-friendly dict."""
        payload = asdict(self)
        payload["tracking_url"] = self.tracking_url()
        return payload


class GarysGuideScraper:
    def __init__(
        self,
        region: str = "nyc",
        session: Optional[requests.Session] = None,
        default_limit: Optional[int] = DEFAULT_FETCH_LIMIT,
    ):
        self.region = region
        self.default_limit = default_limit
        self.session = session or requests.Session()
        self.session.headers.update(
            {
                "User-Agent": (
                    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
                    "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0 Safari/537.36"
                ),
                "Accept-Language": "en-US,en;q=0.9",
            }
        )

    # ------------------------------------------------------------------
    # Public API
    # ------------------------------------------------------------------
    def fetch_events(self, fetch_details: bool = True, limit: Optional[int] = None) -> List[GarysGuideEvent]:
        """Fetch and parse GarysGuide listings."""
        if limit is None:
            limit = self.default_limit
        html = self._get_listing_html()
        soup = BeautifulSoup(html, "html.parser")
        events = self._parse_listing(soup)

        if limit:
            events = events[:limit]

        if fetch_details:
            for event in events:
                detail = self._fetch_event_details(event.link)
                if detail.get("register_link"):
                    event.register_link = detail["register_link"]
                if detail.get("long_description"):
                    event.long_description = detail["long_description"]
                if detail.get("iso_datetime") and not event.iso_datetime:
                    event.iso_datetime = detail["iso_datetime"]
                time.sleep(0.5)  # polite delay

        return events

    def fetch_popular_events(self, **kwargs) -> List[GarysGuideEvent]:
        """Return only events flagged as popular."""
        events = self.fetch_events(**kwargs)
        return [event for event in events if event.is_popular]

    # ------------------------------------------------------------------
    # Internal helpers
    # ------------------------------------------------------------------
    def _get_listing_html(self) -> str:
        params = {"region": self.region} if self.region else None
        url = urljoin(BASE_URL, EVENTS_PATH)
        LOGGER.info("Downloading GarysGuide listings from %s", url)
        resp = self.session.get(url, params=params, timeout=30)
        resp.raise_for_status()
        return resp.text

    def _parse_listing(self, soup: BeautifulSoup) -> List[GarysGuideEvent]:
        events: List[GarysGuideEvent] = []
        processed_rows: set[int] = set()

        for font_title in soup.select("font.ftitle"):
            outer_row = self._resolve_outer_row(font_title)
            if not outer_row:
                continue
            row_id = id(outer_row)
            if row_id in processed_rows:
                continue
            processed_rows.add(row_id)

            cells = outer_row.find_all("td", recursive=False)
            if len(cells) < 3:
                continue

            date_cell = cells[0]
            price_cell = cells[2]
            info_cell = cells[-1]

            title_node = info_cell.select_one("font.ftitle a")
            if not title_node:
                continue

            title = title_node.text.strip()
            detail_href = title_node.get("href", "")
            link = urljoin(BASE_URL, detail_href)

            date_label, time_label = self._parse_date_time(date_cell)
            cost = self._clean_text(price_cell.get_text(" ", strip=True))
            badges = [img.get("alt", "") for img in price_cell.find_all("img")]

            location_node = info_cell.find("font", class_="fdescription")
            location_text = self._clean_text(location_node.get_text(" ", strip=True)) if location_node else ""

            short_desc_node = info_cell.find("font", class_="fgray")
            short_desc = self._clean_text(short_desc_node.get_text(" ", strip=True)) if short_desc_node else ""

            day_label = self._find_previous_label(outer_row, "font", {"class": "fblack"})
            week_label = self._find_previous_label(outer_row, "font", {"class": "fboxtitle"})

            iso_datetime = self._infer_datetime(day_label, date_label, time_label)

            event = GarysGuideEvent(
                title=title,
                link=link,
                date_label=date_label or day_label,
                time_label=time_label,
                cost=cost,
                location=location_text,
                short_description=short_desc,
                badges=badges,
                week_label=week_label,
                iso_datetime=iso_datetime,
            )

            # Flag as popular if section title or badges mention it
            event.is_popular = self._is_popular_event(event)

            events.append(event)

        LOGGER.info("Parsed %s events from GarysGuide listings.", len(events))
        return events

    def _fetch_event_details(self, url: str) -> Dict[str, Optional[str]]:
        try:
            resp = self.session.get(url, timeout=30)
            resp.raise_for_status()
        except Exception as exc:
            LOGGER.warning("Failed to fetch event detail %s: %s", url, exc)
            return {}

        soup = BeautifulSoup(resp.text, "html.parser")

        register_btn = soup.find(
            "a",
            {"class": "fbutton"},
            string=lambda s: isinstance(s, str) and "register" in s.lower(),
        )
        register_link = urljoin(BASE_URL, register_btn["href"]) if register_btn and register_btn.get("href") else None

        details_header = soup.find(
            "font", {"class": "fboxtitle"}, string=lambda s: isinstance(s, str) and "details" in s.lower()
        )
        long_description = None
        if details_header:
            details_table = details_header.find_parent("table")
            if details_table:
                desc_node = details_table.find("font", class_="fdescription")
                if desc_node:
                    long_description = self._clean_text(desc_node.get_text(" ", strip=True))

        calendar_row = soup.find("i", {"class": "far fa-calendar-alt fa-lg"})
        iso_datetime = None
        if calendar_row:
            calendar_td = calendar_row.find_parent("td")
            if calendar_td and calendar_td.find_next_sibling("td"):
                dt_text = self._clean_text(calendar_td.find_next_sibling("td").get_text(" ", strip=True))
                iso_datetime = self._parse_date_string(dt_text)

        return {"register_link": register_link, "long_description": long_description, "iso_datetime": iso_datetime}

    # ------------------------------------------------------------------
    # Static/utility helpers
    # ------------------------------------------------------------------
    @staticmethod
    def _resolve_outer_row(font_title: Tag) -> Optional[Tag]:
        try:
            inner_tr = font_title.find_parent("tr")
            inner_table = inner_tr.find_parent("table")
            info_td = inner_table.find_parent("td")
            outer_tr = info_td.find_parent("tr")
            return outer_tr
        except AttributeError:
            return None

    @staticmethod
    def _parse_date_time(cell: Tag) -> (Optional[str], Optional[str]):
        bold = cell.find("b")
        date_label = bold.get_text(strip=True) if bold else None
        full_text = GarysGuideScraper._clean_text(cell.get_text(" ", strip=True))
        time_label = full_text.replace(date_label, "", 1).strip(" ,@") if date_label and full_text else full_text
        time_label = time_label or None
        return date_label, time_label

    @staticmethod
    def _clean_text(text: Optional[str]) -> str:
        return " ".join(text.split()) if text else ""

    @staticmethod
    def _find_previous_label(row: Tag, tag_name: str, attrs: Dict[str, str]) -> Optional[str]:
        prev = row
        while prev:
            prev = prev.find_previous_sibling("tr")
            if not prev:
                break
            label_node = prev.find(tag_name, attrs=attrs)
            if label_node and label_node.text.strip():
                return label_node.get_text(" ", strip=True)
        return None

    @staticmethod
    def _infer_datetime(day_label: Optional[str], date_label: Optional[str], time_label: Optional[str]) -> Optional[str]:
        pieces = []
        if day_label:
            pieces.append(day_label)
        elif date_label:
            pieces.append(date_label)
        if time_label:
            pieces.append(time_label)

        if not pieces:
            return None

        guess_text = " ".join(pieces)
        parsed = GarysGuideScraper._parse_date_string(guess_text)
        return parsed

    @staticmethod
    def _parse_date_string(text: str) -> Optional[str]:
        if not text:
            return None
        today = datetime.now()
        try:
            parsed = date_parser.parse(text, default=today)
            if parsed.date() < today.date() - timedelta(days=60):
                parsed = parsed.replace(year=parsed.year + 1)
            return parsed.isoformat()
        except (ValueError, TypeError):
            return None

    def _is_popular_event(self, event: GarysGuideEvent) -> bool:
        # Section title sometimes contains "POPULAR" or "FEATURED"
        if event.week_label and any(keyword in event.week_label.lower() for keyword in ["popular", "featured", "hot"]):
            return True

        # Badge alt text may include "Popular Event" or similar
        for badge in event.badges:
            if badge and any(keyword in badge.lower() for keyword in ["popular", "featured", "hot", "trending"]):
                return True

        # Short description occasionally includes keywords
        if event.short_description and any(keyword in event.short_description.lower() for keyword in ["popular", "featured"]):
            return True

        return False


def export_events_to_file(events: Iterable[GarysGuideEvent], destination: str) -> Path:
    """Write the provided events to a JSON file and return the path."""
    path = Path(destination).expanduser().resolve()
    path.parent.mkdir(parents=True, exist_ok=True)
    payload = [event.to_dict() for event in events]
    with path.open("w") as f:
        json.dump(payload, f, indent=2)
    LOGGER.info("Saved %s events to %s", len(payload), path)
    return path


def main() -> None:
    parser = argparse.ArgumentParser(description="Scrape GarysGuide events.")
    parser.add_argument("--limit", type=int, default=None, help="Limit the number of events processed.")
    parser.add_argument("--skip-details", action="store_true", help="Skip fetching individual event pages.")
    parser.add_argument("--popular-only", action="store_true", help="Return only events flagged as popular.")
    parser.add_argument("--export", type=str, default=None, help="Write parsed events to the given JSON file.")

    args = parser.parse_args()

    scraper = GarysGuideScraper()
    if args.popular_only:
        events = scraper.fetch_popular_events(fetch_details=not args.skip_details, limit=args.limit)
    else:
        events = scraper.fetch_events(fetch_details=not args.skip_details, limit=args.limit)

    if args.export:
        export_events_to_file(events, args.export)
    else:
        for idx, event in enumerate(events, 1):
            badge = "🔥 Popular" if event.is_popular else ""
            print(f"{idx}. {event.title} {badge}")
            print(f"   Date: {event.date_label} {event.time_label or ''}".strip())
            if event.location:
                print(f"   Location: {event.location}")
            if event.cost:
                print(f"   Cost: {event.cost}")
            print(f"   Link: {event.tracking_url()}")
            print()


if __name__ == "__main__":
    main()

