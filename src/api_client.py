import os
import requests
from dotenv import load_dotenv

load_dotenv()
URL = "https://health.data.ny.gov/api/v3/views/jr8b-6gh6/query.json"
APP_TOKEN = os.getenv("SOCRATA_APP_TOKEN")

if not APP_TOKEN:
    raise RuntimeError("SOCRATA_APP_TOKEN environment variable is not configured.")

HEADERS = { "X-App-Token": APP_TOKEN }
PAGE_SIZE = 1000

def fetch_season(season):
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
            "page": {
                "pageNumber": page_number,
                "pageSize": PAGE_SIZE
            },
            "includeSynthetic": False
        }

        response = requests.post(URL, headers=HEADERS, json=payload)
        response.raise_for_status()
        rows = response.json()

        print(
            f"  Page {page_number}: "
            f"{len(rows)} records"
        )

        season_rows.extend(rows)

        if len(rows) < PAGE_SIZE:
            break

        page_number += 1

    print(
        f"  {season} complete: "
        f"{len(season_rows)} records\n"
    )
    return season_rows


def fetch_seasons(seasons):
    influenza_data = {}
    for season in seasons:
        influenza_data[season] = fetch_season(season)
    return influenza_data