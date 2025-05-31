{{
    config(
        materialized = 'table',
        alias='stg_user_reservation',
        schema = 'staging',
        description = 'daily stg user from table reservations ',
    )
}}
select ru."name", ru.birth_date, ru.gender,
	su.email, 
	case
    when su.phone_number like '62%' then
      '+' || replace(replace(su.phone_number,'-',''),' ','')
    when su.phone_number LIKE '8%' then
      '+62' || replace(replace(su.phone_number,'-',''),' ','')
    when su.phone_number LIKE '0%' then
      '+62' || SUBSTRING(replace(replace(su.phone_number,'-',''),' ','') FROM 2)
    else
      su.phone_number  --callback, kalau tidak sesuai pattern
  end as phone_number
from analytics.reservation_users ru 
left join analytics.stay_users su on su."name" = ru."name"
	and su.birth_date = ru.birth_date -- karna id di reservation dan stay adalah masing masing PK, dipastikan mereka berbeda, maka alternatif nya adalah nama dan tgl lahir
where ru."_airbyte_extracted_at"::date {{ var('conditional_format') }} '{{ var("date_format") }}' 
