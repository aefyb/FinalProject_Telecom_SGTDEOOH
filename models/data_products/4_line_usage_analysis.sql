{{ config(materialized ="table") }}

-- combine monthly usage record with each line's current plan
WITH usage_details AS (
    SELECT
        lu.usage_id,
        lu.line_id,
        lu.customer_id,
        lu.billing_month,
        lu.data_used_gb,
        lu.voice_minutes,
        lu.sms_count,
        lu.overage_charge,
        lu.total_billed,

        -- retrieve plan currently assigned to each line
        l.plan_id AS current_plan_id,
        mp.plan_name AS current_plan_name,
        mp.monthly_price AS current_monthly_price,
        mp.data_cap_gb AS current_data_cap_gb,

        -- see if line exceeded current plan's data allowance
        CASE
            WHEN mp.data_cap_gb IS NOT NULL
                AND lu.data_used_gb > mp.data_cap_gb
            THEN TRUE
            ELSE FALSE
        END AS exceeds_data_cap

    FROM {{ ref('dim_line_usage') }} lu

    -- match each usage record to corresponding line
    JOIN {{ ref('dim_lines') }} l
        ON lu.line_id = l.line_id

    -- retrieve data allowance and pricing of current plan
    JOIN {{ ref('dim_mobile_plans') }} mp
        ON l.plan_id = mp.plan_id
),

-- find cheaper active plans to accomodate line's usage
plan_recommendations AS (
    SELECT
        ud.*,
        rp.plan_id AS recommended_plan_id,
        rp.plan_name AS recommended_plan_name,
        rp.monthly_price AS recommended_monthly_price

    FROM usage_details ud

    -- evaluate alternative plan per usage record
    LEFT JOIN LATERAL (
        SELECT
            alternative.plan_id,
            alternative.plan_name,
            alternative.monthly_price

        FROM {{ ref('dim_mobile_plans') }} alternative

        -- only consider active plans other than current plan
        WHERE LOWER(alternative.plan_status) = 'active'
            AND alternative.plan_id <> ud.current_plan_id
          
        --   require alternative to have enough data for usage
            AND alternative.data_cap_gb >= ud.data_used_gb
        --   only consider lower monthly price
            AND alternative.monthly_price < ud.current_monthly_price

        -- prioritize cheapest qualifying alternative
        ORDER BY
            alternative.monthly_price ASC,
            alternative.data_cap_gb ASC

        -- return only best qualifying alternative
        LIMIT 1
    ) rp ON TRUE
)

-- show usage details, data allowance violation, and plan recommendation
SELECT
    usage_id,
    line_id,
    customer_id,
    billing_month,

    data_used_gb,
    voice_minutes,
    sms_count,
    overage_charge,
    total_billed,

    current_plan_id,
    current_plan_name,
    current_monthly_price,
    current_data_cap_gb,

    exceeds_data_cap,

-- count usage record exceeding allowance per billing month
    COUNT(*) FILTER (
        WHERE exceeds_data_cap
    ) OVER (
        PARTITION BY billing_month
    ) AS over_limit_line_month_count,

-- calculate avg overage charge for record exceeding allowance
    AVG(overage_charge) FILTER (
        WHERE exceeds_data_cap
    ) OVER (
        PARTITION BY billing_month
    ) AS avg_overage_charge_for_over_limit_lines,

-- calculate avg data usage among record exceeding allowances
    AVG(data_used_gb) FILTER (
        WHERE exceeds_data_cap
    ) OVER (
        PARTITION BY billing_month
    ) AS avg_data_used_for_over_limit_lines,

    recommended_plan_id,
    recommended_plan_name,
    recommended_monthly_price,

-- calculate potential monthly savings if customer swapped to recommendation
    CASE
        WHEN recommended_plan_id IS NOT NULL
        THEN current_monthly_price - recommended_monthly_price
        ELSE 0
    END AS potential_monthly_savings

FROM plan_recommendations