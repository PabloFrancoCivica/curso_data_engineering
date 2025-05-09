{{ config(materialized="incremental", unique_key="order_item_id") }}

with
    src_order_items as (
        select *
        from {{ source("sql_server_dbo", "order_items") }}
        where {{ filtro_no_borrados() }}
    ),

    transformed_order_items as (
        select
            -- Clave primaria compuesta: order_id + product_id
            {{ dbt_utils.generate_surrogate_key(["order_id", "product_id"]) }}
            as order_item_id,
            {{ dbt_utils.generate_surrogate_key(["order_id"]) }} as order_id,
            {{ dbt_utils.generate_surrogate_key(["product_id"]) }} as product_id,
            quantity,
            _fivetran_synced
        from src_order_items
        {% if is_incremental() %}
            where _fivetran_synced > (select max(_fivetran_synced) from {{ this }})
        {% endif %}
    )

select *
from transformed_order_items
