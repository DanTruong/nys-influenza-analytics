from api_client import fetch_seasons
from load_database import load_records

SEASONS = [
    "2009-2010",
    "2010-2011",
    "2011-2012",
    "2012-2013",
    "2013-2014",
    "2014-2015",
    "2015-2016",
    "2016-2017",
    "2017-2018",
    "2018-2019",
    "2019-2020",
]


def main():
    influenza_data = fetch_seasons(SEASONS)
    print("\nRecords by season:")

    for season, rows in influenza_data.items():
        print(f"{season}: {len(rows):,}")

    print("\nDownload complete.")
    load_records(influenza_data)


if __name__ == "__main__":
    main()
