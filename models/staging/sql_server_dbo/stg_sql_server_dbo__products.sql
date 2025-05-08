WITH src_products AS (
    SELECT *
    FROM {{ source('sql_server_dbo', 'products') }}
    WHERE {{ filtro_no_borrados() }}
),

transformed_products AS (
    SELECT 
        {{ dbt_utils.generate_surrogate_key(['product_id']) }} AS product_id,
        CAST(price AS FLOAT) AS price,
        name,
        inventory,
        NULL AS peso
    FROM src_products
),

registro_vacio AS (
    SELECT 
        {{ dbt_utils.generate_surrogate_key(["''"]) }} AS product_id,
        NULL AS price,
        '' AS name,
        NULL AS inventory,
        NULL AS peso
)

SELECT * FROM transformed_products
UNION ALL
SELECT * FROM registro_vacio
