from datetime import datetime

DISEASE_CODES = {
    "INFLUENZA_A": "A",
    "INFLUENZA_B": "B",
    "INFLUENZA_UNSPECIFIED": "C"
}

def insert_location(cursor, row):
    geo = row.get("geocoded_column") or {}

    cursor.execute(
        """
        INSERT INTO location (
            fips,
            county_name,
            latitude,
            longitude,
            region
        )
        VALUES (%s, %s, %s, %s, %s)
        ON CONFLICT (fips) DO NOTHING;
        """,
        (
            row["fips"],
            row["county"],
            geo.get("latitude"),
            geo.get("longitude"),
            row["region"]
        )
    )

def insert_occurrence(cursor, row):
    date = datetime.fromisoformat(
        row["weekendingdate"]
    ).date()

    cursor.execute(
        """
        INSERT INTO occurrence (
            date,
            cdc_week,
            season
        )
        VALUES (%s, %s, %s)
        ON CONFLICT (date) DO NOTHING;
        """,
        (
            date,
            int(row["cdcweek"]),
            row["season"]
        )
    )

def insert_case(cursor, row):
    date = datetime.fromisoformat(
        row["weekendingdate"]
    ).date()

    disease_code = DISEASE_CODES[row["disease"]]

    cursor.execute(
        """
        INSERT INTO cases (
            date,
            fips,
            count,
            code
        )
        VALUES (%s, %s, %s, %s)
        ON CONFLICT (date, fips, code) DO NOTHING;
        """,
        (
            date,
            row["fips"],
            int(row["count"]),
            disease_code
        )
    )