## Fetch data from NYS Health API
import os
import requests

URL = "https://health.data.ny.gov/api/v3/views/jr8b-6gh6/query.json"
appToken = "TzrowUltuo5MRag1iGadIAmmt"


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

headers = {"X-App-Token": os.getenv(appToken)}

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


## Make sure to ingest Season, Region, County, CDC Week, Week Ending, Disease, Count, County Centroid, and FIPS

## Work with County, Week Ending Date (as Date), Disease, Incidents (as Count), and Coordinates (as County Centroid)

## Separate Coordinates into Latitude and Longitude

## Separate date into Month, Day, and Year

## Rename Influenza labels as A, B, and Unspecified

## Aggregate the flu data by sum of incidents (as a consolidated set)