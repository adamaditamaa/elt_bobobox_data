{{
    config(
        materialized = 'incremental',
        alias='dim_rooms',
		unique_key = 'id',
        schema = 'production',
    )
}}
select sr.id,
	sr."name",
		replace(replace(replace(lower(sr.room_type),' ',''),'-',''),'_','') as room_type,
		sr."floor",
		sh."name" || sh."type" as dim_hotelid
	from analytics.stay_rooms sr 
	join analytics.stay_hotels sh on sh.id = sr.hotel_id 
	where sr."_airbyte_extracted_at"::Date {{ var('conditional_format') }} '{{ var("date_format") }}'