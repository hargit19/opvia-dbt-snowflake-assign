{{
    config(
        materialized='table',
        tags=['fact', 'core']
    )
}}

/*
    Fact Model: fct_stock_observations
    
    Purpose:
    - Store time-series observations of stock metrics
    - Enable trending and historical analysis
    - Support joins to dimension tables
    - Provide grain at stock-date level
    
    Grain: One row per stock symbol per observation date
*/

with staged_stocks as (
    
    select * from {{ ref('stg_stocks') }}

),

company_dimension as (
    
    select 
        company_key,
        stock_symbol
    from {{ ref('dim_company') }}

),

stock_facts as (

    select
        -- Surrogate fact key
        {{ dbt_utils.generate_surrogate_key(['s.stock_symbol', 's.last_updated_date']) }} as observation_key,
        
        -- Foreign key to dimension
        c.company_key,
        
        -- Degenerate dimensions (attributes we keep in fact)
        s.stock_symbol,
        
        -- Date dimension (simplified - could be FK to date dimension)
        date(s.last_updated_date) as observation_date,
        s.last_updated_date as observation_timestamp,
        
        -- Additive measures (can be summed across dimensions)
        s.trading_volume,
        s.daily_dollar_volume,
        s.market_cap_usd,
        
        -- Semi-additive measures (can be summed across some dimensions)
        s.stock_price_usd,
        
        -- Non-additive measures (ratios, percentages)
        s.price_earnings_ratio,
        
        -- Calculated metrics
        case 
            when s.market_cap_usd > 0 
            then s.stock_price_usd / (s.market_cap_usd / 1000000000.0)
            else null 
        end as price_to_market_cap_ratio,
        
        round(
            s.trading_volume / 
            nullif(avg(s.trading_volume) over (
                partition by s.stock_symbol 
                order by s.last_updated_date 
                rows between 6 preceding and current row
            ), 0),
            2
        ) as volume_vs_7day_avg,
        
        -- Flags
        case when s.trading_volume > 1000000 then true else false end as is_high_volume,
        case when s.price_earnings_ratio between 10 and 30 then true else false end as is_healthy_pe,
        
        -- Quality indicators
        s.data_quality_score,
        s.data_quality_category,
        
        -- Audit
        current_timestamp() as fact_created_at

    from staged_stocks s
    
    -- Join to dimension to get surrogate key
    inner join company_dimension c
        on s.stock_symbol = c.stock_symbol
    
    -- Only include valid observations
    where s.last_updated_date is not null
        and s.stock_price_usd > 0

)

select * from stock_facts