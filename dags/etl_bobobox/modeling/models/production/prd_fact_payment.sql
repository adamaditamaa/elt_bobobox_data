{{
    config(
        materialized = 'incremental',
        alias='fact_payment',
        schema = 'production',
        unique_key = 'id',
        description = 'main table payment'
    )
}}

with check_dimuser as (
   select id from  {{ ref('prd_dim_users') }} r limit 0
), check_dim_hotel as (
    select id from  {{ ref('prd_dim_hotel') }} r limit 0
),check_dimroom as (
   select id from  {{ ref('prd_dim_payment_method') }} r limit 0
), check_fact_reserv as (
    select id from  {{ ref('prd_fact_reservations') }} r limit 0
)
select 
		pp.id,
		pp.reservation_id as fact_reservation_id,
		pp.payment_method_id as dim_payment_method,
		rh."name" || rh."type" as dim_hotelid,
		ru."name" || replace(ru.birth_date::varchar,'-','') as dim_userid,
		pp.amount,
		pp.status,
		pp.created_datetime,
		pp.payment_datetime 
	from analytics.payment_payments pp 
	join analytics.reservation_reservations rr on rr.id = pp.reservation_id 
	join analytics.reservation_users ru on ru.id = rr.booker_id 
	join analytics.reservation_hotels rh on rh.id = rr.hotel_id 
	where pp."_airbyte_extracted_at"::date {{ var('conditional_format') }} '{{ var("date_format") }}'