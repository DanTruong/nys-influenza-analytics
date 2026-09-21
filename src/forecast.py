import pandas as pd
import warnings
from statsmodels.tools.sm_exceptions import ConvergenceWarning
from statsmodels.tsa.holtwinters import ExponentialSmoothing
from prepare_timeseries import prepare_forecast_timeseries, split_forecast_data
from statsmodels.tsa.statespace.sarimax import SARIMAX
from database import (
    save_forecast_results,
    save_forecast_metrics,
    save_forecast_overall_metrics,
)

import numpy as np

FORECAST_HORIZON = 61
SEASONAL_PERIOD = 52

SARIMA_ORDER = (2, 1, 1)
SARIMA_SEASONAL_ORDER = (0, 0, 1, SEASONAL_PERIOD)


def forecast_sarima(training_data: pd.DataFrame) -> pd.DataFrame:
    """Generate county-level forecasts using the configured SARIMA model.

    A separate SARIMA model is fitted to each county's weekly incident
    series using the configured nonseasonal and seasonal orders.

    Args:
        training_data: County-level weekly training observations.

    Returns:
        County-level forecasts containing forecast dates, FIPS codes,
        predicted incidents, and model convergence status.
    """
    forecasts = []

    for county in sorted(training_data["COUNTY"].unique()):
        county_data = training_data[training_data["COUNTY"] == county].sort_values(
            "DATE"
        )
        fips = county_data["FIPS"].iloc[0]
        incidents = county_data["INCIDENTS"].to_numpy()

        print(f"Fitting SARIMA: {county}")
        model = SARIMAX(
            incidents,
            order=SARIMA_ORDER,
            seasonal_order=SARIMA_SEASONAL_ORDER,
            enforce_stationarity=False,
            enforce_invertibility=False,
        )

        fitted_model = model.fit(disp=False)

        converged = fitted_model.mle_retvals.get("converged", False)

        predictions = fitted_model.forecast(steps=FORECAST_HORIZON)

        forecast_dates = pd.date_range(
            start=county_data["DATE"].max() + pd.Timedelta(weeks=1),
            periods=FORECAST_HORIZON,
            freq="W-SAT",
        )

        county_forecast = pd.DataFrame(
            {
                "DATE": forecast_dates,
                "FIPS": fips,
                "COUNTY": county,
                "SARIMA_FORECAST": predictions,
                "SARIMA_CONVERGED": converged,
            }
        )

        forecasts.append(county_forecast)

    return pd.concat(forecasts, ignore_index=True)


def forecast_holt_winters(
    training_data: pd.DataFrame,
) -> tuple[pd.DataFrame, pd.DataFrame]:
    """Generate county-level additive Holt-Winters forecasts.

    A separate model with 52-week additive seasonality is fitted to each
    county's weekly incident series.

    Args:
        training_data: County-level weekly training observations.

    Returns:
        A tuple containing the county-level forecast DataFrame and a
        DataFrame reporting model convergence status for each county.
    """
    forecasts = []
    convergence_results = []

    for county in sorted(training_data["COUNTY"].unique()):
        county_data = training_data[training_data["COUNTY"] == county].sort_values(
            "DATE"
        )
        fips = county_data["FIPS"].iloc[0]
        incidents = county_data["INCIDENTS"].to_numpy()
        model = ExponentialSmoothing(
            incidents,
            seasonal="add",
            seasonal_periods=SEASONAL_PERIOD,
        )

        with warnings.catch_warnings(record=True) as caught_warnings:
            warnings.simplefilter("always", ConvergenceWarning)
            fitted_model = model.fit()

        converged = not any(
            issubclass(warning.category, ConvergenceWarning)
            for warning in caught_warnings
        )

        convergence_results.append({"COUNTY": county, "CONVERGED": converged})
        predictions = fitted_model.forecast(FORECAST_HORIZON)

        forecast_dates = pd.date_range(
            start=county_data["DATE"].max() + pd.Timedelta(weeks=1),
            periods=FORECAST_HORIZON,
            freq="W-SAT",
        )

        county_forecast = pd.DataFrame(
            {
                "DATE": forecast_dates,
                "FIPS": fips,
                "COUNTY": county,
                "HW_FORECAST": predictions,
                "HW_CONVERGED": converged,
            }
        )
        forecasts.append(county_forecast)

    forecasts = pd.concat(forecasts, ignore_index=True)
    convergence_results = pd.DataFrame(convergence_results)

    return forecasts, convergence_results


def evaluate_forecasts(
    hw_forecasts: pd.DataFrame,
    sarima_forecasts: pd.DataFrame,
    testing_data: pd.DataFrame,
) -> pd.DataFrame:
    """Compare model forecasts with observed testing data.

    Forecasts are aligned with actual county-week observations and
    absolute and squared forecast errors are calculated for both models.

    Args:
        hw_forecasts: Holt-Winters county-level forecasts.
        sarima_forecasts: SARIMA county-level forecasts.
        testing_data: Observed county-level testing data.

    Returns:
        A DataFrame containing forecasts, actual observations,
        convergence indicators, and forecast errors.
    """
    actuals = testing_data.groupby("COUNTY", group_keys=False).head(FORECAST_HORIZON)
    results = hw_forecasts.merge(
        sarima_forecasts, on=["DATE", "FIPS", "COUNTY"], how="inner"
    )

    results = results.merge(
        actuals[["DATE", "FIPS", "COUNTY", "INCIDENTS", "IMPUTED", "OFFSEASON"]],
        on=["DATE", "FIPS", "COUNTY"],
        how="inner",
    )

    results["HW_ERROR"] = results["HW_FORECAST"] - results["INCIDENTS"]
    results["SARIMA_ERROR"] = results["SARIMA_FORECAST"] - results["INCIDENTS"]
    results["HW_SQUARED_ERROR"] = results["HW_ERROR"] ** 2
    results["SARIMA_SQUARED_ERROR"] = results["SARIMA_ERROR"] ** 2

    results["HW_ABSOLUTE_ERROR"] = results["HW_ERROR"].abs()

    results["SARIMA_ABSOLUTE_ERROR"] = results["SARIMA_ERROR"].abs()

    return results


def calculate_forecast_metrics(
    results: pd.DataFrame,
) -> pd.DataFrame:
    """Calculate county-level forecast accuracy metrics.

    Args:
        results: Evaluated Holt-Winters and SARIMA forecasts.

    Returns:
        A DataFrame containing MAE and RMSE for each model and county.
    """
    metrics = (
        results.groupby(["FIPS", "COUNTY"])
        .agg(
            HW_MAE=("HW_ABSOLUTE_ERROR", "mean"),
            HW_RMSE=("HW_SQUARED_ERROR", lambda x: x.mean() ** 0.5),
            SARIMA_MAE=("SARIMA_ABSOLUTE_ERROR", "mean"),
            SARIMA_RMSE=("SARIMA_SQUARED_ERROR", lambda x: x.mean() ** 0.5),
        )
        .reset_index()
    )

    return metrics


def calculate_overall_metrics(
    results: pd.DataFrame,
) -> pd.DataFrame:
    """Calculate overall forecast accuracy metrics.

    Args:
        results: Evaluated Holt-Winters and SARIMA forecasts.

    Returns:
        A DataFrame containing overall MAE and RMSE for each model.
    """
    return pd.DataFrame(
        {
            "MODEL": ["Holt-Winters", "SARIMA"],
            "MAE": [
                results["HW_ABSOLUTE_ERROR"].mean(),
                results["SARIMA_ABSOLUTE_ERROR"].mean(),
            ],
            "RMSE": [
                np.sqrt(results["HW_SQUARED_ERROR"].mean()),
                np.sqrt(results["SARIMA_SQUARED_ERROR"].mean()),
            ],
        }
    )


def main() -> None:
    """Run the county-level forecasting and evaluation pipeline."""
    data = prepare_forecast_timeseries()

    training_data, testing_data = split_forecast_data(data)

    hw_forecasts, convergence_results = forecast_holt_winters(training_data)

    sarima_forecasts = forecast_sarima(training_data)

    results = evaluate_forecasts(hw_forecasts, sarima_forecasts, testing_data)

    print("\nHolt-Winters forecast rows:")
    print(len(hw_forecasts))

    print("\nSARIMA forecast rows:")
    print(len(sarima_forecasts))

    print("\nEvaluation rows:")
    print(len(results))

    print("\nHolt-Winters convergence:")
    print(convergence_results["CONVERGED"].value_counts())

    print("\nNon-converged counties:")
    print(
        convergence_results.loc[~convergence_results["CONVERGED"], "COUNTY"].to_string(
            index=False
        )
    )

    metrics = calculate_forecast_metrics(results)
    overall_metrics = calculate_overall_metrics(results)

    save_forecast_results(results)
    save_forecast_metrics(metrics)
    save_forecast_overall_metrics(overall_metrics)

    print("\nForecast results saved to PostgreSQL.")

    print("\nCounty forecast metrics:")
    print(metrics.to_string(index=False))

    print("\nOverall forecast metrics:")
    print(overall_metrics.to_string(index=False))

    print("\nSARIMA convergence:")
    print(
        sarima_forecasts[["COUNTY", "SARIMA_CONVERGED"]]
        .drop_duplicates()["SARIMA_CONVERGED"]
        .value_counts()
    )

    print("\nNon-converged SARIMA counties:")
    print(
        sarima_forecasts.loc[~sarima_forecasts["SARIMA_CONVERGED"], "COUNTY"]
        .drop_duplicates()
        .to_string(index=False)
    )


if __name__ == "__main__":
    main()
