

-- All Data
with total_stays_per_hotel as (
	select h.id, count(distinct s.guest_id) as total_stays
	from stays s 
	join reservations r on r.id = s.reservation_id 
		and r.status = 'Paid'
	join rooms r2 ON r2.id = s.room_id 
	join hotels h on h.id = r2.hotel_id 
	where  (
            :start_date IS NULL OR s.`date` >= :start_date
        )
        AND
        (
            :end_date IS NULL OR s.`date` <= :end_date
        )
	group by 1
), group_stays as (
	select 
		a.hotel_id,
		a.hotel_name,
		a.gender,
		a.age_group,
		count(distinct a.id) as stays_count
	from (
		select 
			h.id as hotel_id,
			h.name as hotel_name,
			u.gender,
			case 
				when TIMESTAMPDIFF(YEAR, u.birth_date, s.`date`) < 18 then 'Under 18'
				when TIMESTAMPDIFF(YEAR, u.birth_date, s.`date`) between 18 and 24 
					then '18-24'
				when TIMESTAMPDIFF(YEAR, u.birth_date, s.`date`) between 25 and 34 
					then '25-34'
				when TIMESTAMPDIFF(YEAR, u.birth_date, s.`date`) between 35 and 44 
					then '35-44'
				when TIMESTAMPDIFF(YEAR, u.birth_date, s.`date`) between 45 and 54 
					then '45-54'
				when TIMESTAMPDIFF(YEAR, u.birth_date, s.`date`) between 55 and 64 
					then '55-64'
				when TIMESTAMPDIFF(YEAR, u.birth_date, s.`date`) >= 65
					then '65+'
			end as age_group,
			s.`date`,
			u.id 
		from stays s 
		join users u on u.id = s.guest_id 
		join reservations r on r.id = s.reservation_id 
			and r.status = 'Paid'
		join rooms r2 ON r2.id = s.room_id 
		join hotels h on h.id = r2.hotel_id 
		where  (
            :start_date IS NULL OR s.`date` >= :start_date
        )
        AND
        (
            :end_date IS NULL OR s.`date` <= :end_date
        )
	) a
	group by 1,2,3,4
)
	select 
		gs.hotel_name,
		gs.gender,
		gs.age_group,
		gs.stays_count,
		round(((gs.stays_count / tsp.total_stays) * 100),2) as percentage
	from group_stays gs
	join total_stays_per_hotel tsp 
	where :hotel_name IS NULL OR gs.hotel_name = :hotel_name



-- 2 based on Gender
	with total_stays_per_hotel as (
	select h.id, count(distinct s.guest_id) as total_stays
	from stays s 
	join reservations r on r.id = s.reservation_id 
		and r.status = 'Paid'
	join rooms r2 ON r2.id = s.room_id 
	join hotels h on h.id = r2.hotel_id 
	where  (
            :start_date IS NULL OR s.`date` >= :start_date
        )
        AND
        (
            :end_date IS NULL OR s.`date` <= :end_date
        )
	group by 1
), group_stays as (
	select 
		a.hotel_id,
		a.hotel_name,
		a.gender,
		count(distinct a.id) as stays_count
	from (
		select 
			h.id as hotel_id,
			h.name as hotel_name,
			u.gender,
			s.`date`,
			u.id 
		from stays s 
		join users u on u.id = s.guest_id 
		join reservations r on r.id = s.reservation_id 
			and r.status = 'Paid'
		join rooms r2 ON r2.id = s.room_id 
		join hotels h on h.id = r2.hotel_id 
		where  (
            :start_date IS NULL OR s.`date` >= :start_date
        )
        AND
        (
            :end_date IS NULL OR s.`date` <= :end_date
        )
	) a
	group by 1,2,3
)
	select 
		gs.hotel_name,
		gs.gender,
		gs.stays_count,
		round(((gs.stays_count / tsp.total_stays) * 100),2) as percentage
	from group_stays gs
	join total_stays_per_hotel tsp 
	where :hotel_name IS NULL OR gs.hotel_name = :hotel_name
	
	
-- 3 based on Age Group
	
with total_stays_per_hotel as (
	select h.id, count(distinct s.guest_id) as total_stays
	from stays s 
	join reservations r on r.id = s.reservation_id 
		and r.status = 'Paid'
	join rooms r2 ON r2.id = s.room_id 
	join hotels h on h.id = r2.hotel_id 
	where  (
            :start_date IS NULL OR s.`date` >= :start_date
        )
        AND
        (
            :end_date IS NULL OR s.`date` <= :end_date
        )
	group by 1
), group_stays as (
	select 
		a.hotel_id,
		a.hotel_name,
		a.age_group,
		count(distinct a.id) as stays_count
	from (
		select 
			h.id as hotel_id,
			h.name as hotel_name,
			case 
				when TIMESTAMPDIFF(YEAR, u.birth_date, s.`date`) < 18 then 'Under 18'
				when TIMESTAMPDIFF(YEAR, u.birth_date, s.`date`) between 18 and 24 
					then '18-24'
				when TIMESTAMPDIFF(YEAR, u.birth_date, s.`date`) between 25 and 34 
					then '25-34'
				when TIMESTAMPDIFF(YEAR, u.birth_date, s.`date`) between 35 and 44 
					then '35-44'
				when TIMESTAMPDIFF(YEAR, u.birth_date, s.`date`) between 45 and 54 
					then '45-54'
				when TIMESTAMPDIFF(YEAR, u.birth_date, s.`date`) between 55 and 64 
					then '55-64'
				when TIMESTAMPDIFF(YEAR, u.birth_date, s.`date`) >= 65
					then '65+'
			end as age_group,
			s.`date`,
			u.id 
		from stays s 
		join users u on u.id = s.guest_id 
		join reservations r on r.id = s.reservation_id 
			and r.status = 'Paid'
		join rooms r2 ON r2.id = s.room_id 
		join hotels h on h.id = r2.hotel_id 
		where  (
            :start_date IS NULL OR s.`date` >= :start_date
        )
        AND
        (
            :end_date IS NULL OR s.`date` <= :end_date
        )
	) a
	group by 1,2,3
)
	select 
		gs.hotel_name,
		gs.age_group,
		gs.stays_count,
		round(((gs.stays_count / tsp.total_stays) * 100),2) as percentage
	from group_stays gs
	join total_stays_per_hotel tsp 
	where :hotel_name IS NULL OR gs.hotel_name = :hotel_name