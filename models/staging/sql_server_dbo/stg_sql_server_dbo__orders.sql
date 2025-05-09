{{
    config(
        materialized='incremental',
        unique_key='order_id'
    )
}}

WITH src_orders AS (
    SELECT *
    FROM {{ source('sql_server_dbo', 'orders') }}
    WHERE {{ filtro_no_borrados() }}
),

transformed_orders AS (
    SELECT 
        {{ dbt_utils.generate_surrogate_key(['order_id']) }} AS order_id,
        {{ dbt_utils.generate_surrogate_key(['user_id']) }} AS user_id,
        {{ dbt_utils.generate_surrogate_key(['address_id']) }} AS address_id,
        {{ dbt_utils.generate_surrogate_key(['promo_id']) }} AS promo_id,
        CAST(order_cost AS FLOAT) AS order_cost,
        CAST(order_total AS FLOAT) AS order_total,
        CAST(shipping_cost AS FLOAT) AS shipping_cost,
        shipping_service,
        CONVERT_TIMEZONE('Etc/GMT-2', 'UTC', CAST(created_at AS TIMESTAMP_NTZ)) AS created_at,
        CAST(CONVERT_TIMEZONE('Etc/GMT-2', 'UTC', CAST(created_at AS TIMESTAMP_NTZ)) AS DATE) AS created_at_fecha,
        TO_CHAR(CONVERT_TIMEZONE('Etc/GMT-2', 'UTC', CAST(created_at AS TIMESTAMP_NTZ)), 'HH24:MI:SS') AS created_at_time,
        CONVERT_TIMEZONE('Etc/GMT-2', 'UTC', CAST(estimated_delivery_at AS TIMESTAMP_NTZ)) AS estimated_delivery_at,
        CAST(CONVERT_TIMEZONE('Etc/GMT-2', 'UTC', CAST(estimated_delivery_at AS TIMESTAMP_NTZ)) AS DATE) AS estimated_delivery_at_fecha,
        CONVERT_TIMEZONE('Etc/GMT-2', 'UTC', CAST(delivered_at AS TIMESTAMP_NTZ)) AS delivered_at,
        CAST(CONVERT_TIMEZONE('Etc/GMT-2', 'UTC', CAST(delivered_at AS TIMESTAMP_NTZ)) AS DATE) AS delivered_at_fecha,
        tracking_id,
        status,
        _fivetran_synced
    FROM src_orders
    {% if is_incremental() %}
            where _fivetran_synced > (select max(_fivetran_synced) from {{ this }})
    {% endif %}
)

SELECT * FROM transformed_orders
