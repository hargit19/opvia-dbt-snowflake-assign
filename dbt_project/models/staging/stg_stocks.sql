{{
    config(
        materialized='view',
        tags=['staging', 'stocks']
    )
}}

/*
    Staging Model: stg_stocks
    
    Purpose:
    - Clean and standardize raw stock data from the staging table
    - Rename columns to follow dbt naming conventions
    - Standardize data types
    - Handle missing values with appropriate defaults
    - Add metadata fields for lineage tracking
    
    Source: STAGING.STOCK_DATA_CLEAN
*/

with source as (
    
    select * from {{ source('staging', 'stock_data_clean') }}

),

renamed_and_cleaned as (

    select
        -- Primary keys
        stock_key as stock_id,
        symbol as stock_symbol,
        
        -- Descriptive attributes
        trim(company_name) as company_name,
        trim(sector) as sector,
        trim(country) as country,
        
        -- Financial metrics (with proper handling of nulls and negatives)
        market_cap_usd,
        current_price_usd as stock_price_usd,
        daily_volume as trading_volume,
        
        -- PE ratio can be null for unprofitable companies
        case 
            when pe_ratio < 0 then null  -- Negative PE ratios are invalid
            when pe_ratio > 1000 then null  -- Extremely high ratios are likely errors
            else pe_ratio 
        end as price_earnings_ratio,
        
        -- Categorical fields
        market_cap_category,
        
        -- Calculated fields
        case 
            when market_cap_usd > 0 and daily_volume > 0 
            then daily_volume * current_price_usd 
            else 0 
        end as daily_dollar_volume,
        
        -- Data quality
        data_quality_score,
        case 
            when data_quality_score >= 0.9 then 'High'
            when data_quality_score >= 0.7 then 'Medium'
            else 'Low'
        end as data_quality_category,
        
        -- Metadata fields
        source_url,
        first_seen_at as first_observed_date,
        last_updated_at as last_updated_date,
        created_at as record_created_at,
        updated_at as record_updated_at,
        
        -- dbt metadata
        current_timestamp() as dbt_loaded_at,
        '{{ run_started_at }}' as dbt_run_timestamp

    from source
    
    -- Filter out invalid records
    where stock_symbol is not null
        and company_name is not null
        and market_cap_usd >= 0
        and current_price_usd > 0

)

select * from renamed_and_cleaned