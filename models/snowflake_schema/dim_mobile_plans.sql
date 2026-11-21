{{ config(materialized ="table") }}

SELECT
    plan_id,
    plan_name,
    plan_category,
    monthly_price,
    data_cap_gb,
    hotspot_gb,
    includes_5g,
    plan_status
FROM {{ ref('stg_mobile_plans') }}