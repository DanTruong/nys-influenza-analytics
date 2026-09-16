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

INSERT INTO disease (code, description)
VALUES
    ('A', 'Influenza A'),
    ('B', 'Influenza B'),
    ('C', 'Unspecified');