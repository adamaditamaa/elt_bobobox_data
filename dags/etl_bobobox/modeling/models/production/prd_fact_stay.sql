{{
    config(
        materialized = 'incremental',
        alias='fact_stay',
        schema = 'production',
		unique_key = 'id',
        description = 'main table stay'
    )
}}

with check_dimuser as (
   select id from  {{ ref('prd_dim_users') }} r limit 0
), check_dim_hotel as (
    select id from  {{ ref('prd_dim_hotel') }} r limit 0
),check_dimroom as (
   select id from  {{ ref('prd_dim_rooms') }} r limit 0
), check_fact_reserv as (
    select id from  {{ ref('prd_fact_reservations') }} r limit 0
)
select 
		ss.id,
		ss."date",
		ss.reference_reservation_id as fact_reservation_id,
		ss.room_id as dim_roomid,
		su."name" || replace(su.birth_date::varchar,'-','') as dim_userid,
		sh."name" || sh."type" as dim_hotelid
	from analytics.stay_stays ss 
	join analytics.stay_users su on su.id = ss.guest_id 
	join analytics.stay_rooms sr on sr.id = ss.room_id 
	join analytics.stay_hotels sh on sh.id = sr.hotel_id 
	where ss."_airbyte_extracted_at"::date {{ var('conditional_format') }} '{{ var("date_format") }}'