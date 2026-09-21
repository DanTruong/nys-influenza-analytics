import pandas as pd
from database import get_connection


def get_weekly_cases():
    query = """
        SELECT  o.date          AS DATE_OF_RECORD
        ,       o.season        AS SEASON
        ,       l.fips          AS FIPS
        ,       l.county_name   AS COUNTY
        ,       SUM(c.count)    AS INCIDENTS
        FROM cases c
        JOIN occurrence o
            ON c.date = o.date
        JOIN location l
            ON c.fips = l.fips
        GROUP BY
            o.date,
            o.season,
            l.fips,
            l.county_name
        ORDER BY
            l.fips,
            o.date;
    """

    with get_connection() as conn:
        with conn.cursor() as cursor:
            cursor.execute(query)
            rows = cursor.fetchall()
            columns = ["DATE", "SEASON", "FIPS", "COUNTY", "INCIDENTS"]

    return pd.DataFrame(rows, columns=columns)


def normalize_dates(df):
    df["DATE"] = pd.to_datetime(df["DATE"])
    df.loc[df["DATE"] == "2015-04-17", "DATE"] = pd.Timestamp("2015-04-18")
    return df


def fill_missing_weeks(df):
    df["DATE"] = pd.to_datetime(df["DATE"])
    dates = df[["DATE", "SEASON"]].drop_duplicates().sort_values("DATE")
    counties = df[["FIPS", "COUNTY"]].drop_duplicates().sort_values("FIPS")

    complete = (
        dates.assign(key=1).merge(counties.assign(key=1), on="key").drop(columns="key")
    )

    complete = complete.merge(df, on=["DATE", "SEASON", "FIPS", "COUNTY"], how="left")
    complete["IMPUTED"] = complete["INCIDENTS"].isna()
    complete["INCIDENTS"] = complete["INCIDENTS"].fillna(0).astype(int)

    return complete.sort_values(["FIPS", "DATE"]).reset_index(drop=True)


def create_continuous_series(df):
    start_date = df["DATE"].min()
    end_date = df["DATE"].max()

    weekly_dates = pd.DataFrame(
        {"DATE": pd.date_range(start=start_date, end=end_date, freq="W-SAT")}
    )

    counties = df[["FIPS", "COUNTY"]].drop_duplicates().sort_values("FIPS")
    complete = (
        weekly_dates.assign(key=1)
        .merge(counties.assign(key=1), on="key")
        .drop(columns="key")
    )
    complete = complete.merge(df, on=["DATE", "FIPS", "COUNTY"], how="left")

    complete["OFFSEASON"] = complete["SEASON"].isna()
    complete["INCIDENTS"] = complete["INCIDENTS"].fillna(0).astype(int)
    complete["IMPUTED"] = complete["IMPUTED"].fillna(False).astype(bool)

    return complete.sort_values(["FIPS", "DATE"]).reset_index(drop=True)


def prepare_timeseries():
    weekly_cases = get_weekly_cases()
    weekly_cases = normalize_dates(weekly_cases)
    timeseries = fill_missing_weeks(weekly_cases)
    return timeseries


def prepare_forecast_timeseries():
    timeseries = prepare_timeseries()
    forecast_timeseries = create_continuous_series(timeseries)
    return forecast_timeseries


def split_forecast_data(df):
    test_start = pd.Timestamp("2018-10-06")
    training_data = df[df["DATE"] < test_start].copy()
    testing_data = df[df["DATE"] >= test_start].copy()
    return training_data, testing_data