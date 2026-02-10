SELECT 
    DATE_TRUNC('day', f.observation_date) as trading_day,
    COUNT(DISTINCT f.stock_symbol) as stocks_traded,
    SUM(f.trading_volume) as total_share_volume,
    SUM(f.daily_dollar_volume) as total_dollar_volume,
    AVG(f.stock_price_usd) as avg_stock_price,
    SUM(CASE WHEN f.is_high_volume THEN 1 ELSE 0 END) as high_volume_stocks
FROM fact_stock_observations f
GROUP BY DATE_TRUNC('day', f.observation_date)
ORDER BY trading_day DESC
LIMIT 30;
