import pandas as pd
from database import get_connection

TEST_START_DATE = "2018-10-06"


def get_weekly_cases() -> pd.DataFrame:
    """Retrieve county-level weekly influenza totals from PostgreSQL.

    Influenza A, influenza B, and unspecified influenza cases are
    aggregated into a single weekly incident count for each county.

    Returns:
        A DataFrame containing date, season, FIPS code, county, and
        weekly incident count.
    """
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


def normalize_dates(df: pd.DataFrame) -> pd.DataFrame:
    """Normalize source dates to the weekly Saturday reporting schedule.

    The source observation dated April 17, 2015 is shifted to
    April 18, 2015 to align it with the Saturday-based weekly series.

    Args:
        df: Weekly county influenza observations.

    Returns:
        The DataFrame with normalized dates.
    """
    df["DATE"] = pd.to_datetime(df["DATE"])
    df.loc[df["DATE"] == "2015-04-17", "DATE"] = pd.Timestamp("2015-04-18")
    return df


def fill_missing_weeks(df: pd.DataFrame) -> pd.DataFrame:
    """Complete missing county-week observations within influenza seasons.

    A complete combination of reported dates and New York counties is
    constructed. Missing county-week observations are assigned zero
    incidents to reproduce the methodology of the original analysis.
    These observations are identified by the IMPUTED column.

    Args:
        df: Weekly county influenza observations.

    Returns:
        A completed county-week DataFrame with missing observations
        zero-filled and flagged as imputed.
    """
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


def create_continuous_series(df: pd.DataFrame) -> pd.DataFrame:
    """Create continuous weekly time series for all counties.

    Saturday observations are generated continuously between the first
    and last dates in the dataset. Weeks outside reported influenza
    seasons are assigned zero incidents and identified by the OFFSEASON
    column.

    Args:
        df: County-week observations for reported influenza seasons.

    Returns:
        A continuous Saturday-based weekly time series for every county.
    """
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


def prepare_timeseries() -> pd.DataFrame:
    """Prepare reported influenza observations for time-series analysis.

    Returns:
        County-level weekly influenza observations with normalized dates
        and completed county-week combinations.
    """
    weekly_cases = get_weekly_cases()
    weekly_cases = normalize_dates(weekly_cases)
    timeseries = fill_missing_weeks(weekly_cases)
    return timeseries


def prepare_forecast_timeseries() -> pd.DataFrame:
    """Prepare continuous county-level time series for forecasting.

    Returns:
        Continuous weekly influenza time series including zero-filled
        offseason weeks.
    """
    timeseries = prepare_timeseries()
    forecast_timeseries = create_continuous_series(timeseries)
    return forecast_timeseries


def split_forecast_data(
    df: pd.DataFrame,
) -> tuple[pd.DataFrame, pd.DataFrame]:
    """Split the time series into training and testing datasets.

    Observations before TEST_START_DATE are assigned to the training
    dataset. Observations on or after that date are assigned to the
    testing dataset.

    Args:
        df: Continuous county-level influenza time series.

    Returns:
        A tuple containing the training DataFrame followed by the
        testing DataFrame.
    """
    test_start = pd.Timestamp(TEST_START_DATE)
    training_data = df[df["DATE"] < test_start].copy()
    testing_data = df[df["DATE"] >= test_start].copy()
    return training_data, testing_data
