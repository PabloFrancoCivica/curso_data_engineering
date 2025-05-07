SELECT 
    quantity,
    month,
    {{ dbt_utils.generate_surrogate_key(['product_id']) }} AS product_id
FROM {{ source('google_sheets', 'budget') }}
