WITH src_promos AS (
    SELECT *
    FROM {{ source('sql_server_dbo', 'promos') }}
),

transformed_promos AS (
    SELECT 
        {{ dbt_utils.generate_surrogate_key(['PROMO_ID']) }} AS promo_id,
        DISCOUNT AS discount_euros,
        STATUS AS status,
        PROMO_ID AS desc_promo
    FROM src_promos
),

registro_vacio AS (
    SELECT 
        {{ dbt_utils.generate_surrogate_key(["''"]) }} AS promo_id,
        0 AS discount_euros,
        '' AS status,
        '' AS desc_promo
)

SELECT * FROM transformed_promos
UNION ALL
SELECT * FROM registro_vacio