{{
    config(
        materialized = 'incremental',
        alias='fact_reservations',
        schema = 'production',
        unique_key = 'id',
        description = 'main table reservations'
    )
}}

with check_dimuser as (
   select id from  {{ ref('prd_dim_users') }} r limit 0
), check_dim_hotel as (
    select id from  {{ ref('prd_dim_hotel') }} r limit 0
)
select 
		rr.id,
		rr.reservation_datetime,
		rh."name" || rh."type" as dim_hotelid,
		ru."name" || replace(ru.birth_date::varchar,'-','') as dim_userid,
		rr.check_in_date,
		rr.check_out_date,
		rr.total_room_price,
		rr.total_discount,
		rr.status,
		rr.voucher_code 
	from analytics.reservation_reservations rr 
	join analytics.reservation_hotels rh on rh.id = rr.hotel_id 
	join analytics.reservation_users ru on ru.id = rr.booker_id 
	where rr."_airbyte_extracted_at"::date {{ var('conditional_format') }} '{{ var("date_format") }}'