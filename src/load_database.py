from datetime import datetime
from database import get_connection
import psycopg
from typing import Any

SeasonRow = dict[str, Any]
SeasonData = dict[str, list[SeasonRow]]

DISEASE_CODES = {"INFLUENZA_A": "A", "INFLUENZA_B": "B", "INFLUENZA_UNSPECIFIED": "C"}


def insert_location(
    cursor: psycopg.Cursor,
    row: SeasonRow,
) -> None:
    """Insert a county location record if it does not already exist.

    Args:
        cursor: Active PostgreSQL database cursor.
        row: Influenza API record containing county location data.
    """
    geo = row.get("geocoded_column") or {}
    cursor.execute(
        """
        INSERT INTO location (fips, county_name, latitude, longitude, region)
        VALUES (%s, %s, %s, %s, %s)
        ON CONFLICT (fips) DO NOTHING;
        """,
        (
            row["fips"],
            row["county"],
            geo.get("latitude"),
            geo.get("longitude"),
            row["region"],
        ),
    )


def insert_occurrence(
    cursor: psycopg.Cursor,
    row: SeasonRow,
) -> None:
    """Insert a weekly occurrence record if it does not already exist.

    Args:
        cursor: Active PostgreSQL database cursor.
        row: Influenza API record containing date and season information.
    """
    date = datetime.fromisoformat(row["weekendingdate"]).date()
    cursor.execute(
        """
        INSERT INTO occurrence (date, cdc_week, season)
        VALUES (%s, %s, %s)
        ON CONFLICT (date) DO NOTHING;
        """,
        (date, int(row["cdcweek"]), row["season"]),
    )


def insert_case(
    cursor: psycopg.Cursor,
    row: SeasonRow,
) -> None:
    """Insert a county influenza case record if it does not already exist.

    Args:
        cursor: Active PostgreSQL database cursor.
        row: Influenza API record containing case-count information.
    """
    date = datetime.fromisoformat(row["weekendingdate"]).date()
    disease_code = DISEASE_CODES[row["disease"]]
    cursor.execute(
        """
        INSERT INTO cases (date, fips, count, code)
        VALUES (%s, %s, %s, %s)
        ON CONFLICT (date, fips, code) DO NOTHING;
        """,
        (date, row["fips"], int(row["count"]), disease_code),
    )


def load_records(influenza_data: SeasonData) -> None:
    """Load downloaded influenza records into PostgreSQL.

    Records are normalized into the location, occurrence, and cases
    tables.

    Args:
        influenza_data: Influenza API records grouped by season.
    """
    print("\nConnecting to PostgreSQL...")

    with get_connection() as conn:
        with conn.cursor() as cursor:
            for season, rows in influenza_data.items():
                print(f"Loading {season} into PostgreSQL...")

                for row in rows:
                    insert_location(cursor, row)
                    insert_occurrence(cursor, row)
                    insert_case(cursor, row)

                print(f"  {season}: " f"{len(rows):,} records processed")
        conn.commit()
    print("Database load complete.")
