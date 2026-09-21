CREATE TABLE location (
    fips VARCHAR(5) PRIMARY KEY,
    county_name VARCHAR(100) NOT NULL,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    region VARCHAR(50) NOT NULL
);

CREATE TABLE occurrence (
    date DATE PRIMARY KEY,
    cdc_week INTEGER NOT NULL,
    season VARCHAR(9) NOT NULL
);

CREATE TABLE disease (
    code CHAR(1) PRIMARY KEY,
    description VARCHAR(50) NOT NULL
);

CREATE TABLE cases (
    date DATE NOT NULL,
    fips VARCHAR(5) NOT NULL,
    code CHAR(1) NOT NULL,
    count INTEGER NOT NULL,

    PRIMARY KEY (date, fips, code),

    CONSTRAINT fk_cases_occurrence
        FOREIGN KEY (date)
        REFERENCES occurrence(date),

    CONSTRAINT fk_cases_location
        FOREIGN KEY (fips)
        REFERENCES location(fips),

    CONSTRAINT fk_cases_disease
        FOREIGN KEY (code)
        REFERENCES disease(code)
);

CREATE TABLE forecast_results (
    date DATE NOT NULL,
    fips VARCHAR(5) NOT NULL,

    actual INTEGER NOT NULL,

    hw_forecast DOUBLE PRECISION NOT NULL,
    sarima_forecast DOUBLE PRECISION NOT NULL,

    hw_absolute_error DOUBLE PRECISION NOT NULL,
    sarima_absolute_error DOUBLE PRECISION NOT NULL,

    hw_squared_error DOUBLE PRECISION NOT NULL,
    sarima_squared_error DOUBLE PRECISION NOT NULL,

    hw_converged BOOLEAN NOT NULL,
    sarima_converged BOOLEAN NOT NULL,

    PRIMARY KEY (date, fips),

    CONSTRAINT fk_forecast_results_location
        FOREIGN KEY (fips)
        REFERENCES location(fips)
);

CREATE TABLE forecast_metrics (
    fips VARCHAR(5) PRIMARY KEY,

    hw_mae DOUBLE PRECISION NOT NULL,
    hw_rmse DOUBLE PRECISION NOT NULL,

    sarima_mae DOUBLE PRECISION NOT NULL,
    sarima_rmse DOUBLE PRECISION NOT NULL,

    CONSTRAINT fk_forecast_metrics_location
        FOREIGN KEY (fips)
        REFERENCES location(fips)
);

CREATE TABLE forecast_overall_metrics (
    model VARCHAR(50) PRIMARY KEY,
    mae DOUBLE PRECISION NOT NULL,
    rmse DOUBLE PRECISION NOT NULL
);

INSERT INTO disease (code, description)
VALUES
    ('A', 'Influenza A'),
    ('B', 'Influenza B'),
    ('C', 'Unspecified');