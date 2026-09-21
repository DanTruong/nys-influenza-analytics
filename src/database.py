import os
import psycopg
from dotenv import load_dotenv

load_dotenv()


def get_connection():
    return psycopg.connect(
        dbname=os.getenv("POSTGRES_DB"),
        user=os.getenv("POSTGRES_USER"),
        password=os.getenv("POSTGRES_PASSWORD"),
        host=os.getenv("POSTGRES_HOST"),
        port=os.getenv("POSTGRES_PORT")
    )

def save_forecast_results(results):
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
            row.SARIMA_CONVERGED
        )
        for row in results.itertuples(index=False)
    ]

    with get_connection() as conn:
        with conn.cursor() as cursor:
            cursor.execute("TRUNCATE TABLE forecast_results;")
            cursor.executemany(query, rows)

        conn.commit()

def save_forecast_metrics(metrics):
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
        (
            row.FIPS,
            row.HW_MAE,
            row.HW_RMSE,
            row.SARIMA_MAE,
            row.SARIMA_RMSE
        )
        for row in metrics.itertuples(index=False)
    ]

    with get_connection() as conn:
        with conn.cursor() as cursor:
            cursor.execute("TRUNCATE TABLE forecast_metrics;")
            cursor.executemany(query, rows)

        conn.commit()

def save_forecast_overall_metrics(overall_metrics):
    query = """
        INSERT INTO forecast_overall_metrics (
            model,
            mae,
            rmse
        )
        VALUES (%s, %s, %s);
    """

    rows = [
        (
            row.MODEL,
            row.MAE,
            row.RMSE
        )
        for row in overall_metrics.itertuples(index=False)
    ]

    with get_connection() as conn:
        with conn.cursor() as cursor:
            cursor.execute(
                "TRUNCATE TABLE forecast_overall_metrics;"
            )
            cursor.executemany(query, rows)

        conn.commit()