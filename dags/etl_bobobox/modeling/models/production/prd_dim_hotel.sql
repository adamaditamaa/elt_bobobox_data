{{
    config(
        materialized = 'incremental',
        alias='dim_hotel',
        schema = 'production',
		unique_key = 'id',
        description = 'dim hotel from reservations and stay',
    )
}}
with main_reserv as (
	select rh."name", rh."type"
	from analytics.reservation_hotels rh
	where rh."_airbyte_extracted_at"::date {{ var('conditional_format') }} '{{ var("date_format") }}'
), main_stay as (
	select sh."name",sh."type" 
	from analytics.stay_hotels sh 
	left join analytics.reservation_hotels rh on sh."name" = rh."name" and sh."type" = rh."type" 
	where rh.id is null and sh."_airbyte_extracted_at"::date {{ var('conditional_format') }} '{{ var("date_format") }}'
)
	select mr."name" || mr."type" as id,mr."name",mr."type" 
	from main_reserv mr
	union all
	select ms."name" || ms."type" as id ,ms."name" , ms."type" 
	from main_stay ms