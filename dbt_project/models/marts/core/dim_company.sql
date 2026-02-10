{{
    config(
        materialized='table',
        tags=['dimension', 'core']
    )
}}

/*
    Dimension Model: dim_company
    
    Purpose:
    - Create a deduplicated dimension table of companies
    - Provide a stable surrogate key for fact table joins
    - Store slowly changing attributes of companies
    - Support dimensional modeling best practices
    
    Grain: One row per unique company (identified by stock symbol)
*/

with staged_stocks as (
    
    select * from {{ ref('stg_stocks') }}

),

deduplicated_companies as (

    select
        -- Generate surrogate key using dbt_utils (or manual hash)
        {{ dbt_utils.generate_surrogate_key(['stock_symbol']) }} as company_key,
        
        -- Natural key
        stock_symbol,
        
        -- Descriptive attributes (Type 1 SCD - overwrite on change)
        company_name,
        sector,
        country,
        
        -- Classification
        market_cap_category,
        
        -- Market cap used for categorization (take most recent)
        market_cap_usd,
        
        -- Source tracking
        source_url,
        
        -- Temporal attributes
        first_observed_date,
        last_updated_date,
        
        -- Audit columns
        current_timestamp() as created_at,
        current_timestamp() as updated_at,
        true as is_current

    from staged_stocks
    
    -- Deduplicate: keep one record per symbol (most recent)
    qualify row_number() over (
        partition by stock_symbol 
        order by last_updated_date desc
    ) = 1

)

select * from deduplicated_companies
