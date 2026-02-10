USE DATABASE STOCK_ANALYTICS;
USE SCHEMA ANALYTICS;

SELECT 
    c.stock_symbol,
    c.company_name,
    c.sector,
    c.country,
    f.market_cap_usd,
    f.stock_price_usd,
    c.market_cap_category,
    RANK() OVER (ORDER BY f.market_cap_usd DESC) as market_cap_rank
FROM dim_company c
JOIN fact_stock_observations f 
    ON c.company_key = f.company_key
WHERE f.observation_date = (
    SELECT MAX(observation_date) 
    FROM fact_stock_observations
)
ORDER BY f.market_cap_usd DESC
LIMIT 10;
