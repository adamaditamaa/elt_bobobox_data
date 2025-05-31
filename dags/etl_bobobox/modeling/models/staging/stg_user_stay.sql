{{
    config(
        materialized = 'table',
        alias='stg_user_stay',
        schema = 'staging',
        description = 'daily user stay',
    )
}}


select  
	su."name", su.birth_date, su.gender,
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
from analytics.stay_users su 
left join analytics.reservation_users ru on ru."name" = su."name" 
	and ru.birth_date = su.birth_date 
where ru.id is null -- ambil yang tidak terdaftar di reservasi, tapi stay (jika ada)
	and su."_airbyte_extracted_at"::Date {{ var('conditional_format') }} '{{ var("date_format") }}'