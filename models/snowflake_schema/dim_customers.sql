{{ config(materialized ="table") }}

SELECT
    customer_id,
    first_name,
    last_name,
    email,
    market_id,
    customer_segment,
    credit_class,
    customer_since,
    autopay_enabled,
    current_bundle_id
FROM {{ ref('stg_customers') }}