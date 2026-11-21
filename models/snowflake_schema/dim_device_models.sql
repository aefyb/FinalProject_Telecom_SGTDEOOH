{{ config(materialized ="table") }}

SELECT
    device_id,
    make,
    model,
    release_year,
    device_tier,
    network_generation,
    msrp
FROM {{ ref('stg_device_models') }}