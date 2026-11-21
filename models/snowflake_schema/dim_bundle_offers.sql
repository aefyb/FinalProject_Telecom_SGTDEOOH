{{ config(materialized ="table") }}

SELECT
    bundle_id,
    bundle_name,
    description,
    discount_pct,
    min_mobile_lines
FROM {{ ref('stg_bundle_offers') }}