{{ config(materialized ="table") }}

SELECT
    bundle_id,
    product_id
FROM {{ source('sgtdeooh','bundle_requirements') }}