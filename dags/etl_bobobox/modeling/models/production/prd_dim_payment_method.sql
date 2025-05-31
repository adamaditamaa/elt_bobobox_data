{{
    config(
        materialized = 'incremental',
        alias='dim_payment_method',
        unique_key = 'id',
        schema = 'production'
    )
}}

select ppm.id ,ppm."name" payment_name, pptp."name" as third_party_name
	from analytics.payment_payment_methods ppm 
	join analytics.payment_payment_third_parties pptp on pptp.id = ppm.third_party_id 
	where ppm."_airbyte_extracted_at"::date {{ var('conditional_format') }} '{{ var("date_format") }}'
	