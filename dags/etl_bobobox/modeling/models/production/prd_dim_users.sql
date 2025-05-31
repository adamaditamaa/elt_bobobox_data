{{
    config(
        materialized = 'incremental',
        alias='dim_users',
        schema = 'production',
        unique_key = 'id',
        description = 'union all dim users'
    )
}}

select r."name" || replace(r.birth_date::varchar,'-','') as id,"name",r.birth_date,r.gender,
    r.email,r.phone_number
from {{ ref('stg_user_reservations') }} r
union all
select s."name" || replace(s.birth_date::varchar,'-','') as id,
    s."name",s.birth_date,s.gender,s.email,s.phone_number
from {{ ref('stg_user_stay') }} s
