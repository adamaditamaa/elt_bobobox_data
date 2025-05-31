
WITH reservation_diff AS (
    SELECT
        u.id AS user_id,
        u.name AS user_name,
        r.id AS reservation_id,
        r.reservation_datetime,
        r.check_in_date,
        r.check_out_date,
        LAG(r.reservation_datetime) OVER (PARTITION BY u.id ORDER BY r.reservation_datetime) AS prev_reservation_datetime,
        LAG(r.check_out_date) OVER (PARTITION BY u.id ORDER BY r.check_in_date) AS prev_checkout_date
    FROM
        reservations r
    JOIN
        users u ON r.booker_id = u.id
    WHERE
        r.status = 'Paid' 
) ,diffs AS (
    SELECT
        user_id,
        user_name,
        DATEDIFF(reservation_datetime, prev_reservation_datetime) AS days_between_rsv,
        DATEDIFF(prev_checkout_date,check_in_date) AS days_between_stays
    FROM reservation_diff
    WHERE
        prev_reservation_datetime IS NOT NULL
        AND prev_checkout_date IS NOT NULL
)

SELECT
    user_id,
    user_name,
    COUNT(*) + 1 AS total_rsv,  -- untuk menambahkan reservasi pertama kali, karna sebelumnya bersifat null di prev_reserv_time
    ROUND(AVG(days_between_rsv), 2) AS avg_days_between_rsv,
    ROUND(STDDEV(days_between_rsv), 2) AS stddev_days_between_rsv,
    ROUND(AVG(days_between_stays), 2) AS avg_days_between_stays
FROM diffs
GROUP BY user_id, user_name
ORDER BY avg_days_between_rsv DESC;
