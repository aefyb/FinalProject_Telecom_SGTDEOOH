{{ config(materialized="table") }}

-- count consumer per market
WITH market_counts AS (
    SELECT
        sm.market_id,
        sm.market_name,
        sm.state,
        sm.region,

        -- count only UNIQUE consumers
        COUNT(DISTINCT c.customer_id) AS consumer_count
    FROM {{ ref('dim_service_markets') }} sm

    -- match consumer to respective markets
    LEFT JOIN {{ ref('dim_customers') }} c
        ON sm.market_id = c.market_id
        AND LOWER(c.customer_segment)='consumer'

    -- group results by market for market totals
    GROUP BY
        sm.market_id,
        sm.market_name,
        sm.state,
        sm.region
)

-- consumer count and rank markets in ascending and descending order
SELECT
    market_id,
    market_name,
    state,
    region,
    consumer_count,

    -- descending
    RANK() OVER (
        ORDER BY consumer_count DESC
    ) AS most_consumers_rank,

    -- ascending
    RANK() OVER (
        ORDER BY consumer_count ASC
    ) AS least_consumers_rank

FROM market_counts