{{ config(materialized="incremental", unique_key="user_id") }}

with
    src_users as (
        select *
        from {{ source("sql_server_dbo", "users") }}
        where {{ filtro_no_borrados() }}
    ),

    transformed_users as (
        select
            {{ dbt_utils.generate_surrogate_key(["USER_ID"]) }} as user_id,
            {{ dbt_utils.generate_surrogate_key(["ADDRESS_ID"]) }} as address_id,
            first_name,
            last_name,
            email,
            {{ validar_email("EMAIL") }} as valid_gmail,
            {{ validar_telefono("PHONE_NUMBER") }} as phone_number,
            convert_timezone(
                'Etc/GMT-2', 'UTC', cast(created_at as timestamp_ntz)
            ) as created_at,
            convert_timezone(
                'Etc/GMT-2', 'UTC', cast(updated_at as timestamp_ntz)
            ) as updated_at,
            cast(
                convert_timezone(
                    'Etc/GMT-2', 'UTC', cast(created_at as timestamp_ntz)
                ) as date
            ) as created_at_date,
            _fivetran_synced
        from src_users
        {% if is_incremental() %}
            where _fivetran_synced > (select max(_fivetran_synced) from {{ this }})
        {% endif %}
    ),

    registro_vacio as (
        select
            {{ dbt_utils.generate_surrogate_key(["''"]) }} as user_id,
            {{ dbt_utils.generate_surrogate_key(["''"]) }} as address_id,
            '' as first_name,
            '' as last_name,
            '' as email,
            false as valid_gmail,
            '' as phone_number,
            null as created_at,
            null as updated_at,
            null as created_at_date,
            null as _fivetran_synced
    )

select *
from transformed_users
union all
select *
from registro_vacio
