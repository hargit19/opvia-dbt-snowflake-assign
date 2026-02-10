USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;

CREATE DATABASE STOCK_ANALYTICS;

SHOW DATABASES LIKE 'STOCK_ANALYTICS';


USE DATABASE STOCK_ANALYTICS;

CREATE SCHEMA STAGING;

SHOW SCHEMAS IN DATABASE STOCK_ANALYTICS;

USE DATABASE STOCK_ANALYTICS;
USE SCHEMA STAGING;

CREATE OR REPLACE TABLE STAGING.STOCK_DATA_CLEAN (
    stock_key NUMBER AUTOINCREMENT PRIMARY KEY,
    symbol VARCHAR(20) NOT NULL UNIQUE,
    company_name VARCHAR(500) NOT NULL,
    sector VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL,
    market_cap_usd NUMBER(20,2) NOT NULL,
    current_price_usd NUMBER(12,2) NOT NULL,
    daily_volume NUMBER(15,0),
    pe_ratio NUMBER(10,2),
    market_cap_category VARCHAR(20),
    source_url VARCHAR(1000),
    data_quality_score NUMBER(3,2),
    first_seen_at TIMESTAMP_NTZ,
    last_updated_at TIMESTAMP_NTZ,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

INSERT INTO STAGING.STOCK_DATA_CLEAN (
    symbol,
    company_name,
    sector,
    country,
    market_cap_usd,
    current_price_usd,
    daily_volume,
    pe_ratio,
    market_cap_category,
    source_url,
    data_quality_score,
    first_seen_at,
    last_updated_at
)
SELECT 
    symbol,
    COALESCE(company_name,'Unknown'),
    COALESCE(sector,'Unknown'),
    COALESCE(country,'Unknown'),
    market_cap,
    price,
    volume,
    pe_ratio,
    CASE
        WHEN market_cap < 2000000000 THEN 'Small Cap'
        WHEN market_cap BETWEEN 2000000000 AND 10000000000 THEN 'Mid Cap'
        ELSE 'Large Cap'
    END,
    source_url,
    (
        CASE WHEN symbol IS NOT NULL THEN 0.2 ELSE 0 END +
        CASE WHEN company_name IS NOT NULL THEN 0.2 ELSE 0 END +
        CASE WHEN sector IS NOT NULL THEN 0.2 ELSE 0 END +
        CASE WHEN market_cap IS NOT NULL THEN 0.2 ELSE 0 END +
        CASE WHEN price IS NOT NULL THEN 0.2 ELSE 0 END
    ),
    MIN(scraped_at),
    MAX(scraped_at)
FROM FINANCE_DATA.PUBLIC.STOCK_DATA_RAW
GROUP BY
    symbol, company_name, sector, country,
    market_cap, price, volume, pe_ratio, source_url;


SELECT * 
FROM STOCK_ANALYTICS.STAGING.STOCK_DATA_CLEAN
LIMIT 10;


