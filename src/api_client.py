import os
import requests
from dotenv import load_dotenv
from typing import Any

SeasonRow = dict[str, Any]
SeasonData = dict[str, list[SeasonRow]]

load_dotenv()
URL = "https://health.data.ny.gov/api/v3/views/jr8b-6gh6/query.json"
APP_TOKEN = os.getenv("SOCRATA_APP_TOKEN")

if not APP_TOKEN:
    raise RuntimeError("SOCRATA_APP_TOKEN environment variable is not configured.")

HEADERS = {"X-App-Token": APP_TOKEN}
PAGE_SIZE = 1000


def fetch_season(season: str) -> list[SeasonRow]:
    """Fetch all influenza records for a single season.

    Retrieves records from the New York State Health Data SODA API,
    automatically requesting additional pages until the entire season
    has been downloaded.

    Args:
        season: Influenza season in YYYY-YYYY format.

    Returns:
        A list of API records for the requested season.
    """

    print(f"Downloading {season}...")
    season_rows = []
    page_number = 1

    while True:
        payload = {
            "query": f"""
                SELECT *
                WHERE season = '{season}'
                ORDER BY weekendingdate, county, disease
            """,
            "page": {"pageNumber": page_number, "pageSize": PAGE_SIZE},
            "includeSynthetic": False,
        }

        response = requests.post(URL, headers=HEADERS, json=payload)
        response.raise_for_status()
        rows = response.json()

        print(f"  Page {page_number}: " f"{len(rows)} records")

        season_rows.extend(rows)

        if len(rows) < PAGE_SIZE:
            break

        page_number += 1

    print(f"  {season} complete: " f"{len(season_rows)} records\n")
    return season_rows


def fetch_seasons(seasons: list[str]) -> SeasonData:
    """Fetch influenza records for multiple seasons.

    Args:
        seasons: Influenza seasons in YYYY-YYYY format.

    Returns:
        A dictionary mapping each season to its downloaded API records.
    """

    influenza_data = {}
    for season in seasons:
        influenza_data[season] = fetch_season(season)
    return influenza_data
