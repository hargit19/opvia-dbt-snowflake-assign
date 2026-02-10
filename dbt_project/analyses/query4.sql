SELECT 
    c.country,
    COUNT(DISTINCT c.stock_symbol) as company_count,
    COUNT(DISTINCT c.sector) as sector_diversity,
    
    -- Market cap metrics
    SUM(f.market_cap_usd) as total_market_cap,
    AVG(f.market_cap_usd) as avg_market_cap,
    MEDIAN(f.market_cap_usd) as median_market_cap,
    
    -- Trading metrics
    SUM(f.trading_volume) as total_trading_volume,
    SUM(f.daily_dollar_volume) as total_dollar_volume,
    
    -- Price metrics
    AVG(f.stock_price_usd) as avg_stock_price,
    AVG(f.price_earnings_ratio) as avg_pe_ratio,
    
    -- Market cap distribution
    SUM(CASE WHEN c.market_cap_category = 'Large Cap' THEN 1 ELSE 0 END) as large_cap_count,
    SUM(CASE WHEN c.market_cap_category = 'Mid Cap' THEN 1 ELSE 0 END) as mid_cap_count,
    SUM(CASE WHEN c.market_cap_category = 'Small Cap' THEN 1 ELSE 0 END) as small_cap_count,
    
    -- Market share
    ROUND(
        100.0 * SUM(f.market_cap_usd) / 
        SUM(SUM(f.market_cap_usd)) OVER (), 
        2
    ) as market_cap_share_pct

FROM dim_company c
JOIN fact_stock_observations f 
    ON c.company_key = f.company_key
WHERE f.observation_date = (SELECT MAX(observation_date) FROM fact_stock_observations)
GROUP BY c.country
ORDER BY total_market_cap DESC;
