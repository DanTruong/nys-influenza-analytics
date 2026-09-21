import os
import psycopg
import pandas as pd
from dotenv import load_dotenv

load_dotenv()


def get_connection() -> psycopg.Connection:
    """Create a connection to the PostgreSQL database.

    Database connection parameters are read from environment variables.

    Returns:
        An open PostgreSQL connection.
    """
    return psycopg.connect(
        dbname=os.getenv("POSTGRES_DB"),
        user=os.getenv("POSTGRES_USER"),
        password=os.getenv("POSTGRES_PASSWORD"),
        host=os.getenv("POSTGRES_HOST"),
        port=os.getenv("POSTGRES_PORT"),
    )


def save_forecast_results(results: pd.DataFrame) -> None:
    """Replace the stored county-level forecast evaluation results.

    Args:
        results: Forecast evaluation data containing actual observations,
            Holt-Winters and SARIMA forecasts, error measurements, and
            convergence indicators.
    """
    query = """
        INSERT INTO forecast_results (
            date,
            fips,
            actual,
            hw_forecast,
            sarima_forecast,
            hw_absolute_error,
            sarima_absolute_error,
            hw_squared_error,
            sarima_squared_error,
            hw_converged,
            sarima_converged
        )
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s);
    """

    rows = [
        (
            row.DATE,
            row.FIPS,
            row.INCIDENTS,
            row.HW_FORECAST,
            row.SARIMA_FORECAST,
            row.HW_ABSOLUTE_ERROR,
            row.SARIMA_ABSOLUTE_ERROR,
            row.HW_SQUARED_ERROR,
            row.SARIMA_SQUARED_ERROR,
            row.HW_CONVERGED,
            row.SARIMA_CONVERGED,
        )
        for row in results.itertuples(index=False)
    ]

    with get_connection() as conn:
        with conn.cursor() as cursor:
            cursor.execute("TRUNCATE TABLE forecast_results;")
            cursor.executemany(query, rows)

        conn.commit()


def save_forecast_metrics(metrics: pd.DataFrame) -> None:
    """Replace the stored county-level forecast accuracy metrics.

    Args:
        metrics: County-level MAE and RMSE measurements for the
            Holt-Winters and SARIMA models.
    """
    query = """
        INSERT INTO forecast_metrics (
            fips,
            hw_mae,
            hw_rmse,
            sarima_mae,
            sarima_rmse
        )
        VALUES (%s, %s, %s, %s, %s);
    """

    rows = [
        (row.FIPS, row.HW_MAE, row.HW_RMSE, row.SARIMA_MAE, row.SARIMA_RMSE)
        for row in metrics.itertuples(index=False)
    ]

    with get_connection() as conn:
        with conn.cursor() as cursor:
            cursor.execute("TRUNCATE TABLE forecast_metrics;")
            cursor.executemany(query, rows)

        conn.commit()


def save_forecast_overall_metrics(
    overall_metrics: pd.DataFrame,
) -> None:
    """Replace the stored overall forecast accuracy metrics.

    Args:
        overall_metrics: Overall MAE and RMSE measurements for each
            forecasting model.
    """
    query = """
        INSERT INTO forecast_overall_metrics (
            model,
            mae,
            rmse
        )
        VALUES (%s, %s, %s);
    """

    rows = [
        (row.MODEL, row.MAE, row.RMSE)
        for row in overall_metrics.itertuples(index=False)
    ]

    with get_connection() as conn:
        with conn.cursor() as cursor:
            cursor.execute("TRUNCATE TABLE forecast_overall_metrics;")
            cursor.executemany(query, rows)

        conn.commit()
