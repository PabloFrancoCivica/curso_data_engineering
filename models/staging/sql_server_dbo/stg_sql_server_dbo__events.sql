{{
    config(
        materialized='incremental',
        unique_key='event_id'
    )
}}

SELECT 
    {{ dbt_utils.generate_surrogate_key(['event_id']) }} AS event_id,
    {{ dbt_utils.generate_surrogate_key(['user_id']) }} AS user_id,
    {{ dbt_utils.generate_surrogate_key(['product_id']) }} AS product_id,
    {{ dbt_utils.generate_surrogate_key(['order_id']) }} AS order_id,
    session_id,
    event_type,
    page_url,
    created_at
FROM {{ source('sql_server_dbo', 'events') }}
WHERE {{ filtro_no_borrados() }}

