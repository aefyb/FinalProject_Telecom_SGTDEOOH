{{ config(materialized ="table") }}

SELECT
    product_id,
    product_name,
    product_type,
    monthly_price,
    billing_scope
FROM {{ ref('stg_service_products') }}