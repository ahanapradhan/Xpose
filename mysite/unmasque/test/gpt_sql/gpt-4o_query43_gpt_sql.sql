SELECT 
    s_store_name,
    s_store_id,
    SUM(CASE WHEN d_day_name = 'Sunday' THEN ss_sales_price ELSE 0 END) AS sunday_sales,
    SUM(CASE WHEN d_day_name = 'Monday' THEN ss_sales_price ELSE 0 END) AS monday_sales,
    SUM(CASE WHEN d_day_name = 'Tuesday' THEN ss_sales_price ELSE 0 END) AS tuesday_sales,
    SUM(CASE WHEN d_day_name = 'Wednesday' THEN ss_sales_price ELSE 0 END) AS wednesday_sales,
    SUM(CASE WHEN d_day_name = 'Thursday' THEN ss_sales_price ELSE 0 END) AS thursday_sales,
    SUM(CASE WHEN d_day_name = 'Friday' THEN ss_sales_price ELSE 0 END) AS friday_sales,
    SUM(CASE WHEN d_day_name = 'Saturday' THEN ss_sales_price ELSE 0 END) AS saturday_sales
FROM
    store_sales
JOIN
    store ON store_sales.ss_store_sk = store.s_store_sk
JOIN
    date_dim ON store_sales.ss_sold_date_sk = date_dim.d_date_sk
WHERE
    d_year = 2002
    AND d_gmt_offset = -5
GROUP BY
    s_store_name, s_store_id
ORDER BY
    s_store_name, s_store_id, sunday_sales, monday_sales, tuesday_sales, wednesday_sales, thursday_sales, friday_sales, saturday_sales
LIMIT 100;


