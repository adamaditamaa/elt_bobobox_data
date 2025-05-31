{{
    config(
        materialized = 'incremental',
        alias='dim_voucher',
		unique_key = 'voucher_code',
        schema = 'production',
    )
}}

	select  
		pv.code as voucher_code,
		pc."name" campaign_name,
		pv.discount_type,
		pv.discount_value,
		pv.valid_from,
		pv.valid_to 
	from analytics.promotion_vouchers pv 
	join analytics.promotion_campaigns pc on pc.id = pv.campaign_id 
	where pv."_airbyte_extracted_at"::date {{ var('conditional_format') }} '{{ var("date_format") }}'