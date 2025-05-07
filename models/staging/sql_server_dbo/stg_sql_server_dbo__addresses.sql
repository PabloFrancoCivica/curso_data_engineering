select 
    {{ dbt_utils.generate_surrogate_key(['ADDRESS_ID']) }} AS address_id,
    country,
    address,
    LPAD(zipcode::STRING, 5, '0') AS zipcode,
    state
from {{source('sql_server_dbo', 'addresses')}}
where {{ filtro_no_borrados() }}
