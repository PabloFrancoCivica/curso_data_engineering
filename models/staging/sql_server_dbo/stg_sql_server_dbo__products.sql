SELECT 
    {{ dbt_utils.generate_surrogate_key(['product_id']) }} AS product_id,
    CAST(price AS FLOAT) AS price,
    name,
    inventory
FROM {{ source('sql_server_dbo', 'products') }}
WHERE {{ filtro_no_borrados() }}
