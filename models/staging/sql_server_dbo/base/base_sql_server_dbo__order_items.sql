{{
    config(
        materialized='incremental'
    )
}}

SELECT 
    {{ dbt_utils.generate_surrogate_key(['oi.order_id', 'oi.product_id']) }} AS order_item_id, --como hacer que esta es la PK
    {{ dbt_utils.generate_surrogate_key(['oi.order_id']) }} AS order_id,
    {{ dbt_utils.generate_surrogate_key(['oi.product_id']) }} AS product_id,
    quantity,
FROM {{ source('sql_server_dbo', 'order_items') }} 
