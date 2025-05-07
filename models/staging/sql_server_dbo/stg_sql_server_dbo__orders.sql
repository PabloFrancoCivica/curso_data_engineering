{{
    config(
        materialized='incremental',
        unique_key='order_id'
    )
}}

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
    CONVERT_TIMEZONE('Etc/GMT-2', 'UTC', CAST(estimated_delivery_at AS TIMESTAMP_NTZ)) AS estimated_delivery_at,
    CONVERT_TIMEZONE('Etc/GMT-2', 'UTC', CAST(delivered_at AS TIMESTAMP_NTZ)) AS delivered_at,
    tracking_id,
    status
FROM {{ source('sql_server_dbo', 'orders') }}
WHERE {{ filtro_no_borrados() }}
