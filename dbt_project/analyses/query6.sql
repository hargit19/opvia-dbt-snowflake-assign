WITH stock_classification AS (
    SELECT 
        c.stock_symbol,
        c.company_name,
        c.sector,
        c.country,
        c.market_cap_category,
        f.stock_price_usd,
        f.price_earnings_ratio,
        f.trading_volume,
        f.volume_vs_7day_avg,
        f.market_cap_usd,
        
        -- Classify as Value or Growth
        CASE 
            WHEN f.price_earnings_ratio < 15 THEN 'Value'
            WHEN f.price_earnings_ratio > 25 THEN 'Growth'
            ELSE 'Blend'
        END as value_growth_category,
        
        -- Risk indicators
        CASE 
            WHEN f.volume_vs_7day_avg > 1.5 THEN 'High Momentum'
            WHEN f.volume_vs_7day_avg < 0.7 THEN 'Low Momentum'
            ELSE 'Stable'
        END as momentum_category,
        
        -- Quality score (simplified)
        CASE 
            WHEN f.price_earnings_ratio BETWEEN 10 AND 30 
                AND f.trading_volume > 500000 
                AND f.data_quality_score > 0.9
            THEN 'High Quality'
            WHEN f.data_quality_score > 0.7
            THEN 'Medium Quality'
            ELSE 'Low Quality'
        END as quality_category

    FROM dim_company c
    JOIN fact_stock_observations f 
        ON c.company_key = f.company_key
    WHERE f.observation_date = (SELECT MAX(observation_date) FROM fact_stock_observations)
        AND f.price_earnings_ratio IS NOT NULL
)

SELECT 
    value_growth_category,
    quality_category,
    COUNT(*) as stock_count,
    ROUND(AVG(stock_price_usd), 2) as avg_price,
    ROUND(AVG(price_earnings_ratio), 2) as avg_pe_ratio,
    ROUND(SUM(market_cap_usd) / 1000000000, 2) as total_market_cap_billions,
    ROUND(AVG(volume_vs_7day_avg), 2) as avg_volume_trend
FROM stock_classification
GROUP BY value_growth_category, quality_category
ORDER BY value_growth_category, quality_category;


-- Show specific recommendations
SELECT 
    stock_symbol,
    company_name,
    sector,
    market_cap_category,
    ROUND(stock_price_usd, 2) as price,
    ROUND(price_earnings_ratio, 2) as pe_ratio,
    value_growth_category,
    momentum_category,
    quality_category,
    
    -- Investment thesis
    CASE 
        WHEN value_growth_category = 'Value' AND quality_category = 'High Quality'
        THEN 'Value Pick - Undervalued Quality Stock'
        WHEN value_growth_category = 'Growth' AND momentum_category = 'High Momentum'
        THEN 'Growth Pick - Strong Momentum'
        WHEN quality_category = 'High Quality' AND pe_ratio BETWEEN 15 AND 25
        THEN 'Balanced Pick - Fair Value Quality'
        ELSE 'Monitor'
    END as investment_thesis

FROM stock_classification
WHERE quality_category IN ('High Quality', 'Medium Quality')
ORDER BY 
    CASE value_growth_category 
        WHEN 'Value' THEN 1 
        WHEN 'Blend' THEN 2 
        ELSE 3 
    END,
    price_earnings_ratio
LIMIT 25;
