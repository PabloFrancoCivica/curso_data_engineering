{{
    config(
        materialized='incremental',
        unique_key='user_id'
    )
}}

SELECT 
    {{ dbt_utils.generate_surrogate_key(['USER_ID']) }} AS user_id,
    {{ dbt_utils.generate_surrogate_key(['ADDRESS_ID']) }} AS address_id,
    first_name,
    last_name,
    email,
    {{ validar_email('EMAIL') }} AS valid_gmail,
    {{ validar_telefono('PHONE_NUMBER') }} AS phone_number,
    CONVERT_TIMEZONE('Etc/GMT-2', 'UTC', CAST(created_at AS TIMESTAMP_NTZ)) AS created_at,
    CONVERT_TIMEZONE('Etc/GMT-2', 'UTC', CAST(updated_at AS TIMESTAMP_NTZ)) AS updated_at
FROM {{ source('sql_server_dbo', 'users') }}
WHERE {{ filtro_no_borrados() }}
