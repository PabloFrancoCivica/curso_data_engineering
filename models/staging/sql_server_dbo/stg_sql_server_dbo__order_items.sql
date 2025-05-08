{{
    config(
        materialized='incremental'
    )
}}

WITH src_order_items AS (
    SELECT *
    FROM {{ source('sql_server_dbo', 'order_items') }}
    WHERE {{ filtro_no_borrados() }}
),

transformed_order_items AS (
    SELECT 
        -- Clave primaria compuesta: order_id + product_id
        {{ dbt_utils.generate_surrogate_key(['order_id', 'product_id']) }} AS order_item_id, 
        {{ dbt_utils.generate_surrogate_key(['order_id']) }} AS order_id,
        {{ dbt_utils.generate_surrogate_key(['product_id']) }} AS product_id,
        quantity
    FROM src_order_items
)

SELECT * FROM transformed_order_items
