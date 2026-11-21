{{ config(materialized ="table") }}

SELECT DISTINCT ON (usage_id)
    usage_id,
    line_id,
    customer_id,
    billing_month,
    data_used_gb,
    voice_minutes,
    sms_count,
    overage_charge,
    total_billed
FROM {{ source('sgtdeooh', 'line_usage') }}
ORDER BY
    usage_id,
    (data_used_gb IS NOT NULL) DESC