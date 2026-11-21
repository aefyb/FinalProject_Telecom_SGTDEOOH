{{ config(materialized ="table") }}

-- retrieve customers and currently assigned bundles
WITH all_customers AS (
    SELECT
        customer_id,
        current_bundle_id
    FROM {{ ref('dim_customers') }}
),

-- count distinct customers with active subscriptions per service
service_counts AS (
    SELECT
        cs.product_id,
        COUNT(DISTINCT cs.customer_id) AS subscriber_count
    FROM {{ ref('fact_customer_services') }} cs
    JOIN all_customers c
        ON cs.customer_id = c.customer_id
    WHERE LOWER(cs.service_status) = 'active'
    GROUP BY cs.product_id
),

-- count active lines per mobile plan
plan_counts AS (
    SELECT
        l.plan_id,
        COUNT(DISTINCT l.line_id) AS subscriber_count
    FROM {{ ref('dim_lines') }} l
    JOIN all_customers c
        ON l.customer_id = c.customer_id
    WHERE LOWER(l.line_status) = 'active'
    GROUP BY l.plan_id
),

-- count customers per bundle
bundle_counts AS (
    SELECT
        current_bundle_id AS bundle_id,
        COUNT(DISTINCT customer_id) AS subscriber_count
    FROM all_customers
    WHERE current_bundle_id IS NOT NULL
    GROUP BY current_bundle_id
),

-- count active lines per device model
device_counts AS (
    SELECT
        l.device_id,
        COUNT(DISTINCT l.line_id) AS subscriber_count
    FROM {{ ref('dim_lines') }} l
    JOIN all_customers c
        ON l.customer_id = c.customer_id
    WHERE LOWER(l.line_status) = 'active'
    GROUP BY l.device_id
),

-- join subscription counts for services, plans, bundles, and devices
subscription_totals AS (

    -- include all products, including zero subscribers
    SELECT
        'Service' AS subscription_type,
        sp.product_id AS subscription_id,
        sp.product_name AS subscription_name,
        COALESCE(sc.subscriber_count, 0) AS subscriber_count
    FROM {{ ref('dim_service_products') }} sp
    LEFT JOIN service_counts sc
        ON sp.product_id = sc.product_id

    UNION ALL

    -- all mobile plans
    SELECT
        'Plan',
        mp.plan_id,
        mp.plan_name,
        COALESCE(pc.subscriber_count, 0)
    FROM {{ ref('dim_mobile_plans') }} mp
    LEFT JOIN plan_counts pc
        ON mp.plan_id = pc.plan_id

    UNION ALL

    -- all bundle offers
    SELECT
        'Bundle',
        bo.bundle_id,
        bo.bundle_name,
        COALESCE(bc.subscriber_count, 0)
    FROM {{ ref('dim_bundle_offers') }} bo
    LEFT JOIN bundle_counts bc
        ON bo.bundle_id = bc.bundle_id

    UNION ALL

    -- all device models
    SELECT
        'Device',
        dm.device_id,
        CONCAT(dm.make, ' ', dm.model),
        COALESCE(dc.subscriber_count, 0)
    FROM {{ ref('dim_device_models') }} dm
    LEFT JOIN device_counts dc
        ON dm.device_id = dc.device_id
)

-- separate rankings for each subscription category
SELECT
    subscription_type,
    subscription_id,
    subscription_name,
    subscriber_count,

    -- most subscribed ranking
    RANK() OVER (
        PARTITION BY subscription_type
        ORDER BY subscriber_count DESC
    ) AS most_subscribed_rank,

    -- least subscribed ranking
    RANK() OVER (
        PARTITION BY subscription_type
        ORDER BY subscriber_count ASC
    ) AS least_subscribed_rank

FROM subscription_totals