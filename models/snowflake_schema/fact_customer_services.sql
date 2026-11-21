{{ config(materialized ="table") }}

SELECT
    customer_service_id,
    customer_id,
    product_id,
    line_id,
    start_date,
    service_status,
    monthly_charge
FROM {{ ref('stg_customer_services') }}