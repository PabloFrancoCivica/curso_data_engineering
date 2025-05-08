WITH src_addresses AS (
    SELECT *
    FROM {{ source('sql_server_dbo', 'addresses') }}
    WHERE {{ filtro_no_borrados() }}
),

transformed_addresses AS (
    SELECT 
        {{ dbt_utils.generate_surrogate_key(['ADDRESS_ID']) }} AS address_id,
        country,
        address,
        LPAD(zipcode::STRING, 5, '0') AS zipcode,
        state,
        '' AS municipio
    FROM src_addresses
),

registro_vacio AS (
    SELECT 
        {{ dbt_utils.generate_surrogate_key(["''"]) }} AS address_id,
        '' AS country,
        '' AS address,
        '' AS zipcode,
        '' AS state,
        '' AS municipio
)

SELECT * FROM transformed_addresses
UNION ALL
SELECT * FROM registro_vacio
