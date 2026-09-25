# NYS Influenza Analytics

A modern data analytics pipeline for analyzing and forecasting county-level influenza activity across New York State.

This project modernizes a graduate Biomedical & Health Informatics project originally developed in 2019 using R and Shiny. The current implementation rebuilds the analytical workflow around Python, PostgreSQL, Docker, and Power BI while preserving the original project's focus on historical influenza trends and county-level forecasting.

## Project Overview

The project retrieves historical influenza surveillance data from the New York State Department of Health, transforms and stores the data in PostgreSQL, constructs continuous county-level time series, generates influenza forecasts using two statistical models, and visualizes the resulting data in Power BI.

The primary goals of the project are to demonstrate:

- REST API data ingestion with Python
- Data cleaning and transformation
- Relational database design with PostgreSQL
- Reproducible development environments with Docker
- Time-series preparation and forecasting
- Model evaluation
- Power BI data modeling and visualization

## Architecture

```text
New York State Open Data API
            │
            ▼
     Python API Client
            │
            ▼
   Data Transformation
            │
            ▼
       PostgreSQL
            │
            ├──────────────────────┐
            │                      │
            ▼                      ▼
 Time-Series Preparation     Power BI
            │
            ▼
    Forecasting Models
            │
     ┌──────┴──────┐
     ▼             ▼
Holt-Winters     SARIMA
     │             │
     └──────┬──────┘
            ▼
    Model Evaluation
            │
            ▼
       PostgreSQL
            │
            ▼
         Power BI
```

## Technology Stack

| Component | Technology |
|---|---|
| Data Source | New York State Open Data |
| Data Ingestion | Python, Requests |
| Data Transformation | Python, Pandas |
| Database | PostgreSQL |
| Database Access | Psycopg |
| Forecasting | Statsmodels |
| Containerization | Docker / Docker Compose |
| Visualization | Microsoft Power BI |

## Data Source

Influenza surveillance data is retrieved from the New York State Department of Health through the NYS Open Data API.

Dataset:

**Influenza Laboratory-Confirmed Cases by County: Beginning 2009-10 Season**

The project retrieves historical observations by influenza season using the NYS SODA API.

The source data includes:

- Influenza season
- Reporting week
- County
- FIPS code
- NYS region
- Disease classification
- Laboratory-confirmed case count
- County geographic coordinates

The analysis covers influenza seasons beginning with **2009-2010** and includes data through **2019-2020**.

## Database Design

Raw API observations are normalized into a relational PostgreSQL schema.

### Source Tables

#### `location`

Stores county-level geographic information.

```text
fips
county_name
latitude
longitude
region
```

#### `occurrence`

Stores reporting-period information.

```text
date
cdc_week
season
```

#### `disease`

Lookup table for influenza classifications.

```text
code
description
```

Disease codes include:

```text
A → Influenza A
B → Influenza B
C → Unspecified
```

#### `cases`

Stores county-level influenza observations.

```text
date
fips
code
count
```

The composite primary key is:

```text
(date, fips, code)
```

### Analytics Tables

Forecasting results are written back to PostgreSQL for downstream analysis and visualization.

#### `forecast_results`

Contains weekly county-level observations, forecasts, forecast errors, and convergence status.

```text
date
fips
actual
hw_forecast
sarima_forecast
hw_absolute_error
sarima_absolute_error
hw_squared_error
sarima_squared_error
hw_converged
sarima_converged
```

#### `forecast_metrics`

Contains county-level model evaluation metrics.

```text
fips
hw_mae
hw_rmse
sarima_mae
sarima_rmse
```

#### `forecast_overall_metrics`

Contains aggregate evaluation metrics for each forecasting model.

```text
model
mae
rmse
```

## Data Preparation

The raw influenza dataset only contains observations during each influenza reporting season.

Forecasting requires a continuous weekly time series, so the analytical pipeline constructs a complete weekly sequence for each county.

The resulting analytical series contains:

- 62 New York counties
- 549 continuous weeks per county
- 34,038 county-week observations
- Dates from October 10, 2009 through April 11, 2020

### Missing Data

The 2014-2015 season contains incomplete county-level reporting in the source dataset.

To remain consistent with the methodology used in the original graduate project, missing county/week observations during this season are represented as zero in the analytical time series.

These observations are identified using an `IMPUTED` indicator and do not modify the original source records stored in PostgreSQL.

Offseason weeks inserted to create the continuous time series are separately identified using an `OFFSEASON` indicator.

This distinguishes:

```text
Source zero       → observed value of zero
Imputed zero      → missing seasonal observation represented as zero
Offseason zero    → inserted week outside the reporting season
```

## Training and Testing Data

The continuous time series is divided into training and testing periods.

### Training

```text
October 10, 2009 – September 29, 2018
```

- 469 weeks per county
- 29,078 county-week observations

### Testing

```text
October 6, 2018 – April 11, 2020
```

- 80 weeks per county
- 4,960 county-week observations

The forecasting evaluation uses a **61-week forecast horizon**.

## Forecasting Models

Two statistical forecasting approaches are evaluated independently for each New York county.

### Holt-Winters Exponential Smoothing

An additive seasonal Holt-Winters model is fitted with a 52-week seasonal period.

```python
ExponentialSmoothing(
    incidents,
    seasonal="add",
    seasonal_periods=52
)
```

### SARIMA

The second model uses Seasonal AutoRegressive Integrated Moving Average modeling.

```text
SARIMA(2,1,1)(0,0,1)[52]
```

implemented using Statsmodels `SARIMAX`.

Model convergence status is retained with the forecast results rather than suppressing convergence warnings.

## Model Evaluation

Forecast accuracy is evaluated using:

- Mean Absolute Error (MAE)
- Root Mean Squared Error (RMSE)

Across the 3,782 county-week forecast observations, the overall results are:

| Model | MAE | RMSE |
|---|---:|---:|
| Holt-Winters | 20.42 | 70.15 |
| SARIMA | 26.16 | 82.22 |

These aggregate values summarize performance across all counties and forecast weeks. County-level metrics are also stored in `forecast_metrics` because forecasting performance varies substantially between counties.

The goal of this project is not to establish a universally superior influenza forecasting model, but to demonstrate a reproducible workflow for preparing, forecasting, evaluating, storing, and visualizing time-series data.

## Power BI Dashboard

The included Power BI report provides an interactive geographic visualization of influenza activity across New York State.

County locations are plotted using latitude and longitude coordinates stored in PostgreSQL.

The map compares:

- **Actual** laboratory-confirmed cases
- **Holt-Winters** estimates
- **SARIMA** estimates

Bubble size represents the magnitude of influenza activity. During the forecast evaluation period, the map displays the three series together for comparison.

A date-range slicer allows users to explore influenza activity across the historical dataset.

Because forecast results are only available during the evaluation period, dates outside the forecasting period display historical Actual observations only.

### Using the PBIX Without PostgreSQL

The Power BI report uses **Import mode**.

As a result, the `.pbix` file contains an imported snapshot of the data and can be opened and explored without running PostgreSQL or Docker.

The database environment is only required when:

- Reproducing the complete pipeline
- Refreshing the Power BI dataset
- Regenerating the source data
- Regenerating forecast results

This allows the Power BI report to function as a standalone demonstration while retaining a fully reproducible data pipeline.

## Project Structure

```text
.
├── src/
│   ├── api_client.py
│   ├── database.py
│   ├── ingest_data.py
│   ├── load_database.py
│   ├── prepare_timeseries.py
│   ├── forecast.py
│   └── compare_legacy.py
│
├── sql/
│   └── ...
│
├── docker-compose.yml
├── Dockerfile
├── requirements.txt
├── .env.example
└── README.md
```

### Python Components

`api_client.py`
: Retrieves influenza data from the NYS Open Data API.

`database.py`
: Manages PostgreSQL connectivity and persistence of analytical results.

`load_database.py`
: Transforms API responses and loads the normalized PostgreSQL schema.

`ingest_data.py`
: Coordinates ingestion of the configured influenza seasons.

`prepare_timeseries.py`
: Aggregates county-level cases, handles missing observations, inserts offseason weeks, and constructs continuous weekly time series.

`forecast.py`
: Fits Holt-Winters and SARIMA models, generates forecasts, evaluates model performance, and stores the results in PostgreSQL.

`compare_legacy.py`
: Development utility for comparing the modern forecasting implementation with output from the original R-based project.

## Running the Project

### Requirements

You will need:

- Docker
- Docker Compose
- A NYS Open Data application token

Clone the repository and create your local environment configuration from `.env.example`.

For example:

```text
POSTGRES_DB=bhi_influenza
POSTGRES_USER=bhi_user
POSTGRES_PASSWORD=<your password>
POSTGRES_PORT=5432
SOCRATA_APP_TOKEN=<your NYS Open Data token>
```

Do not commit `.env` or API credentials to source control.

### Start the Environment

Build and start the PostgreSQL database and ingestion environment:

```bash
docker compose up -d
```

The ingestion service retrieves the configured influenza seasons and populates PostgreSQL.

### Run Forecasting

Forecast generation is intentionally kept separate from normal database startup.

Run:

```bash
docker compose run --rm ingestion python src/forecast.py
```

This:

1. Reads the historical data from PostgreSQL
2. Constructs continuous county-level time series
3. Fits the forecasting models
4. Generates the test-period forecasts
5. Calculates evaluation metrics
6. Writes forecast results and metrics back to PostgreSQL

Forecasting may take some time because models are fitted independently for each county.

### Run Individual Utilities

Any project script can be executed through the ingestion container:

```bash
docker compose run --rm ingestion python src/<script>.py
```

### Stop the Environment

```bash
docker compose down
```

The PostgreSQL Docker volume is retained, so the database remains available the next time the environment is started.

To avoid deleting the stored database, do not use:

```bash
docker compose down -v
```

unless you intentionally want to remove the PostgreSQL volume and rebuild the database.

## Power BI Refresh

The included PBIX can be explored without starting the Docker environment.

To refresh the report from PostgreSQL:

1. Start the PostgreSQL container.
2. Ensure the ingestion and forecasting stages have been completed.
3. Open the PBIX in Power BI Desktop.
4. Configure the PostgreSQL data-source credentials for the local environment if necessary.
5. Refresh the imported dataset.

Power Query performs additional transformations used by the visualization layer, including construction of the combined map dataset containing historical Actual observations and forecast estimates.

## Original Graduate Project

This repository is a modernization of a graduate project completed as part of an M.S. in Biomedical & Health Informatics.

The original implementation used:

- R
- Shiny
- R-based data transformation
- Holt-Winters forecasting
- ARIMA forecasting
- Interactive geographic visualization

The modern implementation is not intended to reproduce every numerical result of the original R implementation exactly. Differences between statistical libraries, model initialization, optimization procedures, and forecasting implementations can produce different numerical forecasts even when using similar model families.

Instead, this project preserves the original analytical problem while demonstrating how the workflow can be implemented using a contemporary data analytics stack.

The original R/Shiny implementation is maintained separately as a historical companion project.
