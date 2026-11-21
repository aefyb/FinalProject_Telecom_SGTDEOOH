{{ config(materialized ="table") }}

SELECT
    bundle_id,
    bundle_name,
    description,
    discount_pct,
    min_mobile_lines
FROM {{ source('sgtdeooh','bundle_offers') }}