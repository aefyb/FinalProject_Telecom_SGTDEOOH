{{ config(materialized ="table") }}

SELECT
    line_id,
    customer_id,
    plan_id,
    device_id,
    activation_date,
    contract_end_date,
    line_status,
    masked_phone_number
FROM {{ source('sgtdeooh','lines') }}