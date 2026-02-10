WITH sector_metrics AS (
    SELECT 
        c.sector,
        f.observation_date,
        
        -- Aggregate metrics
        COUNT(DISTINCT c.stock_symbol) as stock_count,
        AVG(f.stock_price_usd) as avg_price,
        AVG(f.price_earnings_ratio) as avg_pe_ratio,
        SUM(f.market_cap_usd) as total_market_cap,
        SUM(f.trading_volume) as total_volume,
        
        -- Valuation metrics
        MEDIAN(f.stock_price_usd) as median_price,
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY f.stock_price_usd) as price_q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY f.stock_price_usd) as price_q3

    FROM dim_company c
    JOIN fact_stock_observations f 
        ON c.company_key = f.company_key
    GROUP BY c.sector, f.observation_date
),

current_vs_previous AS (
    SELECT 
        sector,
        stock_count,
        avg_price as current_avg_price,
        avg_pe_ratio as current_pe_ratio,
        total_market_cap as current_market_cap,
        total_volume as current_volume,
        
        -- Compare to previous period (if exists)
        LAG(avg_price) OVER (PARTITION BY sector ORDER BY observation_date) as prev_avg_price,
        LAG(total_market_cap) OVER (PARTITION BY sector ORDER BY observation_date) as prev_market_cap,
        
        observation_date
    FROM sector_metrics
)

SELECT 
    sector,
    stock_count,
    ROUND(current_avg_price, 2) as avg_stock_price,
    ROUND(current_pe_ratio, 2) as avg_pe_ratio,
    ROUND(current_market_cap / 1000000000, 2) as market_cap_billions,
    current_volume as trading_volume,
    
    -- Growth calculations
    CASE 
        WHEN prev_avg_price IS NOT NULL AND prev_avg_price > 0
        THEN ROUND(100.0 * (current_avg_price - prev_avg_price) / prev_avg_price, 2)
        ELSE NULL
    END as price_change_pct,
    
    CASE 
        WHEN prev_market_cap IS NOT NULL AND prev_market_cap > 0
        THEN ROUND(100.0 * (current_market_cap - prev_market_cap) / prev_market_cap, 2)
        ELSE NULL
    END as market_cap_change_pct,
    
    -- Market concentration
    ROUND(
        100.0 * current_market_cap / SUM(current_market_cap) OVER (),
        2
    ) as market_share_pct

FROM current_vs_previous
WHERE observation_date = (SELECT MAX(observation_date) FROM sector_metrics)
ORDER BY current_market_cap DESC;
