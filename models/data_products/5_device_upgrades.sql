{{ config(materialized ="table") }}

-- find account product customers don't currently have active
WITH account_upgrade AS (
    SELECT
        'Account' AS opportunity_scope,

        c.customer_id,
        NULL AS line_id,

        c.customer_segment,
        c.market_id,
        sm.market_name,
        sm.state,
        sm.region,

        c.current_bundle_id,

        sp.product_id,
        sp.product_name,
        sp.product_type,
        sp.billing_scope

    FROM {{ ref('dim_customers') }} c

    -- retrieve market association of customer
    JOIN {{ ref('dim_service_markets') }} sm
        ON c.market_id = sm.market_id

    -- generate combinations of customers and available products
    CROSS JOIN {{ ref('dim_service_products') }} sp

    -- check if each customer already has active subscription to product
    LEFT JOIN {{ ref('fact_customer_services') }} cs
        ON c.customer_id = cs.customer_id
        AND sp.product_id = cs.product_id
        AND LOWER(cs.service_status) = 'active'

    -- limit results to specific account-level product
    WHERE sp.product_id IN (
        'SVC-01', 'SVC-02', 'SVC-03', 'SVC-05', 'SVC-07'
    )
        AND LOWER(sp.billing_scope) = 'account'

        -- keep only products without existing active subscription
        AND cs.customer_service_id IS NULL
),

-- find line products that active lines don't have
line_upgrade AS (
    SELECT
        'Line' AS opportunity_scope,

        c.customer_id,
        l.line_id,

        c.customer_segment,
        c.market_id,
        sm.market_name,
        sm.state,
        sm.region,

        c.current_bundle_id,

        sp.product_id,
        sp.product_name,
        sp.product_type,
        sp.billing_scope

    FROM {{ ref('dim_lines') }} l

    -- match each line to corresponding customer
    JOIN {{ ref('dim_customers') }} c
        ON l.customer_id = c.customer_id

    -- retrieve market association of customer
    JOIN {{ ref('dim_service_markets') }} sm
        ON c.market_id = sm.market_id

    -- generate combination of active line and available products
    CROSS JOIN {{ ref('dim_service_products') }} sp

    -- check whether line already has active subscription to product
    LEFT JOIN {{ ref('fact_customer_services') }} cs
        ON l.line_id = cs.line_id
        AND sp.product_id = cs.product_id
        AND LOWER(cs.service_status) = 'active'

    -- only consider active lines and specified line product
    WHERE LOWER(l.line_status) = 'active'
        AND sp.product_id IN ('SVC-04', 'SVC-06', 'SVC-08')
        AND LOWER(sp.billing_scope) = 'line'

        -- keep only product without existing active subscription
        AND cs.customer_service_id IS NULL
)

-- combine account and line upgrade opportunities
SELECT * FROM account_upgrade

UNION ALL

SELECT * FROM line_upgrade