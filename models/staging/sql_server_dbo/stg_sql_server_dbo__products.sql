WITH src_products AS (
    SELECT *
    FROM {{ source('sql_server_dbo', 'products') }}
    WHERE {{ filtro_no_borrados() }}
),

-- Transformamos los datos del origen
transformed_products AS (
    SELECT 
        {{ dbt_utils.generate_surrogate_key(['product_id']) }} AS product_id,
        CAST(price AS FLOAT) AS price,
        name,
        inventory
    FROM src_products
),

-- Cargamos el seed de pesos
plant_weights AS (
    SELECT *
    FROM {{ ref('plant_weight') }}
),

-- Unimos los productos con el seed para obtener el peso
products_with_weight AS (
    SELECT 
        tp.product_id,
        tp.price,
        tp.name,
        tp.inventory,
        pw.weight_kg AS weight_kg
    FROM transformed_products tp
    LEFT JOIN plant_weights pw
        ON LOWER(tp.name) = LOWER(pw.plant_name)
),

-- Registro vacío para mantener estructura uniforme
registro_vacio AS (
    SELECT 
        {{ dbt_utils.generate_surrogate_key(["''"]) }} AS product_id,
        NULL AS price,
        '' AS name,
        NULL AS inventory,
        NULL AS weight_kg
)

-- Resultado final
SELECT * FROM products_with_weight
UNION ALL
SELECT * FROM registro_vacio
