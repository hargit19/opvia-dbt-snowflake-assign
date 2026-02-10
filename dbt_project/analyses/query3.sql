WITH stock_stats AS (
    SELECT 
        stock_symbol,
        AVG(trading_volume) as avg_volume,
        STDDEV(trading_volume) as stddev_volume,
        AVG(stock_price_usd) as avg_price,
        STDDEV(stock_price_usd) as stddev_price
    FROM fact_stock_observations
    WHERE observation_date >= DATEADD('day', -30, CURRENT_DATE())
    GROUP BY stock_symbol
),

current_observations AS (
    SELECT 
        f.stock_symbol,
        c.company_name,
        c.sector,
        f.trading_volume,
        f.stock_price_usd,
        f.observation_date
    FROM fact_stock_observations f
    JOIN dim_company c ON f.company_key = c.company_key
    WHERE f.observation_date = (SELECT MAX(observation_date) FROM fact_stock_observations)
),

outliers AS (
    SELECT 
        co.stock_symbol,
        co.company_name,
        co.sector,
        co.trading_volume,
        co.stock_price_usd,
        ss.avg_volume,
        ss.avg_price,
        
        -- Z-score for volume (outlier if |z| > 2)
        CASE 
            WHEN ss.stddev_volume > 0 
            THEN (co.trading_volume - ss.avg_volume) / ss.stddev_volume
            ELSE 0
        END as volume_z_score,
        
        -- Z-score for price
        CASE 
            WHEN ss.stddev_price > 0 
            THEN (co.stock_price_usd - ss.avg_price) / ss.stddev_price
            ELSE 0
        END as price_z_score,
        
        -- Percentile ranking
        PERCENT_RANK() OVER (ORDER BY co.trading_volume) as volume_percentile,
        PERCENT_RANK() OVER (ORDER BY co.stock_price_usd) as price_percentile
        
    FROM current_observations co
    JOIN stock_stats ss ON co.stock_symbol = ss.stock_symbol
)

SELECT 
    stock_symbol,
    company_name,
    sector,
    trading_volume,
    ROUND(avg_volume, 0) as avg_30day_volume,
    ROUND(volume_z_score, 2) as volume_z_score,
    stock_price_usd,
    ROUND(avg_price, 2) as avg_30day_price,
    ROUND(price_z_score, 2) as price_z_score,
    CASE 
        WHEN ABS(volume_z_score) > 3 THEN 'Extreme Outlier'
        WHEN ABS(volume_z_score) > 2 THEN 'Moderate Outlier'
        ELSE 'Normal'
    END as outlier_status
FROM outliers
WHERE ABS(volume_z_score) > 2 OR ABS(price_z_score) > 2
ORDER BY ABS(volume_z_score) DESC
LIMIT 20;
