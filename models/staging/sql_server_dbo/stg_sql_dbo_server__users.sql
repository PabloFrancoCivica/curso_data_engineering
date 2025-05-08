{{
    config(
        materialized='incremental',
        unique_key='user_id'
    )
}}

WITH src_users AS (
    SELECT *
    FROM {{ source('sql_server_dbo', 'users') }}
    WHERE {{ filtro_no_borrados() }}
),

transformed_users AS (
    SELECT 
        {{ dbt_utils.generate_surrogate_key(['USER_ID']) }} AS user_id,
        {{ dbt_utils.generate_surrogate_key(['ADDRESS_ID']) }} AS address_id,
        first_name,
        last_name,
        email,
        {{ validar_email('EMAIL') }} AS valid_gmail,
        {{ validar_telefono('PHONE_NUMBER') }} AS phone_number,
        CONVERT_TIMEZONE('Etc/GMT-2', 'UTC', CAST(created_at AS TIMESTAMP_NTZ)) AS created_at,
        CONVERT_TIMEZONE('Etc/GMT-2', 'UTC', CAST(updated_at AS TIMESTAMP_NTZ)) AS updated_at,
        CAST(CONVERT_TIMEZONE('Etc/GMT-2', 'UTC', CAST(created_at AS TIMESTAMP_NTZ)) AS DATE) AS created_at_date
    FROM src_users
),

registro_vacio AS (
    SELECT 
        {{ dbt_utils.generate_surrogate_key(["''"]) }} AS user_id,
        {{ dbt_utils.generate_surrogate_key(["''"]) }} AS address_id,
        '' AS first_name,
        '' AS last_name,
        '' AS email,
        false AS valid_gmail,
        '' AS phone_number,
        NULL AS created_at,
        NULL AS updated_at,
        NULL AS created_at_date
)

SELECT * FROM transformed_users
UNION ALL
SELECT * FROM registro_vacio
