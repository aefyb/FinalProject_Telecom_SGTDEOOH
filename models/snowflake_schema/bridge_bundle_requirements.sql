{{ config(materialized ="table") }}

SELECT
    bundle_id,
    product_id
FROM {{ ref('stg_bundle_requirements') }}