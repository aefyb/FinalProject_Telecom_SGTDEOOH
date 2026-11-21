{{ config(materialized ="table") }}

-- aggregate monthly usage records into customer-level billing totals
WITH usage_by_customer AS (
    SELECT
        customer_id,

        -- total overage charge across all records
        SUM(overage_charge) AS total_overage_charges,

        -- total amount billed across all records
        SUM(total_billed) AS historical_total_billed,

        -- most recent billing month per customer
        MAX(billing_month) AS latest_billing_month
    FROM {{ ref('dim_line_usage') }}

    -- group usage recrd by customer to calculate individual total
    GROUP BY customer_id
),

-- combine customer autopay info with billing total
customer_billing AS (
    SELECT
        c.customer_id,

        -- make autopay flag readable
        CASE
            WHEN LOWER(c.autopay_enabled) = 'y' THEN 'Enabled'
            WHEN LOWER(c.autopay_enabled) = 'n' THEN 'Disabled'
            ELSE 'Unknown'
        END AS autopay_status,

        -- replace missing billing amount with zero
        COALESCE(u.total_overage_charges, 0) AS total_overage_charges,
        COALESCE(u.historical_total_billed, 0) AS historical_total_billed,
        u.latest_billing_month

    FROM {{ ref('dim_customers') }} c

    -- retain customers even with no recorded usage
    LEFT JOIN usage_by_customer u
        ON c.customer_id = u.customer_id
)

-- customer and billing activity by autopay status
SELECT
    autopay_status,
    
    -- count # of customers per autopay category
    COUNT(DISTINCT customer_id) AS customer_count,

    -- count # of customers incurring overage charge
    COUNT(DISTINCT customer_id) FILTER (
        WHERE total_overage_charges > 0
    ) AS customers_with_overage_charges,

    -- calculate combined overage charge per autopay category
    SUM(total_overage_charges) AS total_overage_charges,

    -- calculate historical billed amt
    SUM(historical_total_billed) AS historical_total_billed,

    -- find latest billing month per category
    MAX(latest_billing_month) AS latest_billing_month

-- group results by autopay status to compare categories
FROM customer_billing
GROUP BY autopay_status