import pandas as pd

from forecast import forecast_holt_winters

from prepare_timeseries import prepare_forecast_timeseries, split_forecast_data

LEGACY_FILE = "legacy-data/arimaTable.csv"


def load_legacy_forecasts() -> pd.DataFrame:
    """Load and normalize Holt-Winters forecasts from the legacy R analysis.

    Returns:
        A DataFrame containing cleaned legacy county forecasts.
    """
    legacy = pd.read_csv(LEGACY_FILE)

    legacy = legacy.dropna(subset=["County", "HW", "Time_Period"]).copy()

    legacy["Time_Period"] = legacy["Time_Period"].astype(int)

    legacy["HW"] = pd.to_numeric(legacy["HW"])

    legacy["COUNTY"] = legacy["County"].str.upper()

    return legacy


def compare_holt_winters(
    forecasts: pd.DataFrame,
    convergence_results: pd.DataFrame,
    legacy: pd.DataFrame,
) -> pd.DataFrame:
    """Compare modern Holt-Winters forecasts with legacy R forecasts.

    Modern forecasts are aligned with the legacy forecast periods and
    compared both as raw predictions and after reproducing the legacy
    absolute-value and rounding transformation.

    Args:
        forecasts: Holt-Winters forecasts produced by the Python model.
        convergence_results: County-level Python model convergence results.
        legacy: Holt-Winters forecasts from the original R analysis.

    Returns:
        A DataFrame containing aligned forecasts and comparison metrics.
    """
    modern = forecasts.copy()

    modern["TIME_PERIOD"] = modern.groupby("COUNTY").cumcount() + 1

    modern["HW_V1_STYLE"] = modern["HW_FORECAST"].abs().round()

    comparison = modern.merge(
        legacy[["COUNTY", "Time_Period", "HW"]],
        left_on=["COUNTY", "TIME_PERIOD"],
        right_on=["COUNTY", "Time_Period"],
        how="inner",
    )

    comparison["LEGACY_HW_V1_STYLE"] = comparison["HW"].abs().round()

    comparison["RAW_DIFFERENCE"] = comparison["HW_FORECAST"] - comparison["HW"]

    comparison["ABS_DIFFERENCE"] = comparison["RAW_DIFFERENCE"].abs()

    comparison["V1_STYLE_MATCH"] = (
        comparison["HW_V1_STYLE"] == comparison["LEGACY_HW_V1_STYLE"]
    )

    comparison = comparison.merge(convergence_results, on="COUNTY", how="left")

    return comparison


def summarize_comparison(comparison: pd.DataFrame) -> None:
    """Print summary statistics for the legacy forecast comparison.

    Args:
        comparison: Aligned modern and legacy Holt-Winters forecasts.
    """
    print("\nComparison rows:")
    print(len(comparison))

    print("\nExact V1-style matches:")
    print(comparison["V1_STYLE_MATCH"].value_counts())

    print("\nMean absolute raw difference:")
    print(comparison["ABS_DIFFERENCE"].mean())

    print("\nMaximum absolute raw difference:")
    print(comparison["ABS_DIFFERENCE"].max())

    print("\nMean absolute difference by convergence:")
    print(comparison.groupby("CONVERGED")["ABS_DIFFERENCE"].mean())

    print("\nCounties with largest mean differences:")
    print(
        comparison.groupby(["COUNTY", "CONVERGED"])["ABS_DIFFERENCE"]
        .mean()
        .sort_values(ascending=False)
        .head(15)
    )


def main() -> None:
    """Run the legacy Holt-Winters forecast comparison."""
    data = prepare_forecast_timeseries()

    training_data, _ = split_forecast_data(data)

    forecasts, convergence_results = forecast_holt_winters(training_data)

    legacy = load_legacy_forecasts()

    comparison = compare_holt_winters(forecasts, convergence_results, legacy)

    summarize_comparison(comparison)


if __name__ == "__main__":
    main()
