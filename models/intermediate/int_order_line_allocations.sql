{{ config(materialized='incremental') }}

WITH order_items AS (
    SELECT
        order_id,
        product_id,
        quantity
    FROM {{ ref('stg_sql_server_dbo__order_items') }}
),

orders AS (
    SELECT
        *
    FROM {{ ref('stg_sql_server_dbo__orders') }}
),

products AS (
    SELECT
        product_id,
        price,
        weight_kg  -- crear este campo 
    FROM {{ ref('stg_sql_server_dbo__products') }}
),

joined AS (
    SELECT
        oi.quantity, o.*, p.*
    FROM order_items oi
    INNER JOIN orders o ON oi.order_id = o.order_id
    INNER JOIN products p ON oi.product_id = p.product_id
),

enriched AS (
    SELECT
        *,
        price * quantity AS line_total,
        quantity * weight_kg AS line_weight,
        round(order_cost + shipping_cost - order_total,2) AS promo_discount
    FROM joined
),

--Agrupo por pedido para calcular proporciones globales
totales_por_pedido AS (
    SELECT
        order_id,
        -- Total de unidades compradas en el pedido
        SUM(quantity) AS total_quantity,
        -- Total de peso del pedido (suma de peso de cada línea)
        SUM(quantity * weight_kg) AS total_weight
    FROM enriched
    GROUP BY order_id
),

--Calculo proporciones y repartos por línea
final AS (
    SELECT
        e.*,
        -- Proporción del total de unidades que representa esta línea
        CASE 
            WHEN t.total_quantity > 0 THEN e.quantity / t.total_quantity
            ELSE NULL
        END AS proporcion_productos,
        -- Proporción del total de peso del pedido que representa esta línea
        CASE 
            WHEN t.total_weight > 0 THEN e.line_weight / t.total_weight
            ELSE NULL
        END AS proporcion_peso,
        -- Reparto del descuento promocional proporcional al número de unidades
        CASE 
            WHEN t.total_quantity > 0 THEN e.promo_discount * (e.quantity / t.total_quantity)
            ELSE NULL
        END AS promo_discount_allocated,
        -- Reparto del shipping proporcional al peso de la línea
        CASE 
            WHEN t.total_weight > 0 THEN e.shipping_cost * (e.line_weight / t.total_weight)
            ELSE NULL
        END AS shipping_cost_allocated

    FROM enriched e
    INNER JOIN totales_por_pedido t ON e.order_id = t.order_id
)

SELECT * FROM final
order by order_id