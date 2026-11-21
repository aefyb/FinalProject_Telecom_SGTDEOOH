{{ config(materialized ="table") }}

SELECT
    market_id,
    market_name,
    state,
    region,
    five_g_coverage_pct
FROM {{ ref('stg_service_markets') }}