{{
    config(
        materialized='incremental'
    )
}}

SELECT 
    order_item_id, --como hacer que esta es la PK
    order_id,
    product_id,
    quantity,
    quantity * p.price AS total_price
FROM {{ ref('sql_server_dbo', 'order_items') }} oi
LEFT JOIN {{ ref('sql_server_dbo', 'products') }} p
    ON oi.product_id = p.product_id
