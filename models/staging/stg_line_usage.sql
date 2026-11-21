{{ config(materialized ="table") }}

SELECT
    usage_id,
    line_id,
    customer_id,
    billing_month,
    data_used_gb,
    voice_minutes,
    sms_count,
    overage_charge,
    total_billed
FROM {{ source('sgtdeooh','line_usage') }}