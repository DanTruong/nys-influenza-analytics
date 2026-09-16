## Fetch data from NYS Health API
import os
import requests
from dotenv import load_dotenv
from db import get_connection
from load_data import insert_location, insert_occurrence, insert_case

# Load variables from .env
load_dotenv()
URL = "https://health.data.ny.gov/api/v3/views/jr8b-6gh6/query.json"
app_token = os.getenv("SOCRATA_APP_TOKEN")

if not app_token:
    raise RuntimeError(
        "SOCRATA_APP_TOKEN environment variable is not configured."
    )

headers = {
    "X-App-Token": app_token
}

seasons = [
    "2009-2010",
    "2010-2011",
    "2011-2012",
    "2012-2013",
    "2013-2014",
    "2014-2015",
    "2015-2016",
    "2016-2017",
    "2017-2018",
    "2018-2019"
]

page_size = 1000

# Each season will become a key containing a list of records
influenza_data = {}

for season in seasons:

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
                "pageSize": page_size
            },
            "includeSynthetic": False
        }

        response = requests.post(URL, headers=headers, json=payload)
        response.raise_for_status()
        rows = response.json()

        print(f"  Page {page_number}: {len(rows)} records")
        season_rows.extend(rows)

        # If fewer than page_size records were returned,
        # we've reached the final page.
        if len(rows) < page_size:
            break

        page_number += 1

    influenza_data[season] = season_rows

    print(f"  {season} complete: {len(season_rows)} records\n")

    print("\nRecords by season:")
    for season, rows in influenza_data.items():
        print(f"{season}: {len(rows):,}")

print("Download complete.")

## Convert the JSON data into an SQL database

print("\nConnecting to PostgreSQL...")

with get_connection() as conn:
    with conn.cursor() as cursor:

        for season, rows in influenza_data.items():

            print(f"Loading {season} into PostgreSQL...")

            for row in rows:
                insert_location(cursor, row)
                insert_occurrence(cursor, row)
                insert_case(cursor, row)

            print(f"  {season}: {len(rows):,} records processed")

    conn.commit()

print("Database load complete.")
