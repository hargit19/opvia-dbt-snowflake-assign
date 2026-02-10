# Stock Analytics dbt Project - Hardik Advani (Assignment X Opvia)

This dbt project transforms raw stock market data into analytics-ready tables following dimensional modeling best practices.

## Project Structure

```
dbt_project/
├── dbt_project.yml          # Project configuration
├── profiles.yml             # Snowflake connection (copy to ~/.dbt/)
├── packages.yml             # dbt dependencies
├── models/
│   ├── staging/
│   │   ├── sources.yml      # Source table definitions
│   │   └── stg_stocks.sql   # Staging transformation
│   ├── marts/core/
│   │   ├── dim_company.sql           # Company dimension
│   │   └── fct_stock_observations.sql # Stock facts
│   └── schema.yml           # Model tests and documentation
```

## Data Flow

```
RAW.STOCK_DATA_RAW (Snowflake source)
         ↓
    stg_stocks (view)
    - Clean column names
    - Handle nulls
    - Add calculated fields
         ↓
    ┌────────────────┬──────────────────────┐
    ↓                ↓                      ↓
dim_company      fct_stock_observations
(table)          (table)
- Deduped        - Time series
- 1 row/company  - Stock metrics
- Surrogate key  - Foreign keys
```

## Models

### Staging Layer

**stg_stocks.sql**
- **Materialization**: View (no storage cost)
- **Purpose**: Clean and standardize source data
- **Transformations**:
  - Rename columns to snake_case
  - Filter invalid PE ratios (<0 or >1000)
  - Calculate daily dollar volume
  - Add data quality categorization
  - Filter out records with null symbols or zero prices

### Core Layer (Marts)

**dim_company.sql**
- **Materialization**: Table
- **Grain**: One row per unique company
- **Key**: MD5 hash of stock symbol
- **SCD Type**: Type 1 (overwrite)
- **Purpose**: Provide stable reference for company attributes

**fct_stock_observations.sql**
- **Materialization**: Table
- **Grain**: One row per stock per observation date
- **Keys**: 
  - `observation_key`: Surrogate key (hash of symbol + date)
  - `company_key`: Foreign key to dim_company
- **Measures**:
  - Additive: trading_volume, daily_dollar_volume, market_cap_usd
  - Semi-additive: stock_price_usd
  - Non-additive: price_earnings_ratio, ratios
- **Calculated Metrics**:
  - `volume_vs_7day_avg`: Volume ratio to 7-day moving average
  - `is_high_volume`: Flag for volume >1M
  - `is_healthy_pe`: Flag for PE between 10-30

## Tests

### Generic Tests (schema.yml)

- **Uniqueness**: All surrogate keys and natural keys
- **Not Null**: Required fields (keys, names, metrics)
- **Relationships**: `fct_stock_observations.company_key` → `dim_company.company_key`
- **Accepted Values**: Sectors, market cap categories
- **Range Checks**: PE ratio bounds, positive prices

### Custom Tests (dbt_utils)

- **expression_is_true**: Price >0, market cap >=0
- **Range validation**: Data quality score between 0-1

## Running the Project

### First Time Setup

1. **Install dbt**:
```bash
pip install dbt-snowflake
```

2. **Configure profile**:
```bash
mkdir -p ~/.dbt
cp profiles.yml ~/.dbt/profiles.yml
# Edit ~/.dbt/profiles.yml with your Snowflake credentials
```

3. **Install packages**:
```bash
dbt deps  # Installs dbt_utils and dbt_expectations
```

### Regular Workflow

```bash
# Verify connection
dbt debug

# Run all models
dbt run

# Run specific model
dbt run --select stg_stocks

# Run model and downstream dependencies
dbt run --select stg_stocks+

# Test data quality
dbt test

# Test specific model
dbt test --select dim_company

# Full refresh (rebuild tables from scratch)
dbt run --full-refresh

# Generate documentation
dbt docs generate
dbt docs serve  # Opens localhost:8080
```

### Development Workflow

```bash
# Develop new model
dbt run --select my_new_model --target dev

# Test it
dbt test --select my_new_model

# Check lineage
dbt run --select +my_new_model+  # Include upstream and downstream

# Preview compiled SQL
dbt compile --select my_new_model
# Check target/compiled/stock_analytics/models/...
```

## Configuration

### Materializations

- **Staging models**: `view` (defined in dbt_project.yml)
  - Fast to rebuild
  - No storage cost
  - Always fresh data

- **Marts models**: `table` (defined in dbt_project.yml)
  - Better query performance
  - Suitable for BI tools
  - Rebuild on each run (consider incremental for large datasets)

### Schemas

- **Staging**: `STAGING` schema (defined in sources.yml)
- **Marts**: `ANALYTICS` schema (defined in dbt_project.yml)
