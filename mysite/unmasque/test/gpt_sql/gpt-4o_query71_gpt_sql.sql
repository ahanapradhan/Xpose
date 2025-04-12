SELECT 
    i_brand,
    i_brand_id,
    EXTRACT(HOUR FROM ss_sold_time) AS sale_hour,
    EXTRACT(MINUTE FROM ss_sold_time) AS sale_minute,
    SUM(ss_net_paid) + SUM(cs_net_paid) + SUM(ws_net_paid) AS total_sales_revenue
FROM
    store_sales
JOIN
    item ON ss_item_sk = i_item_sk
JOIN
    store ON ss_store_sk = s_store_sk
JOIN
    catalog_sales ON cs_item_sk = i_item_sk
JOIN
    web_sales ON ws_item_sk = i_item_sk
JOIN
    time_dim ON ss_sold_time_sk = t_time_sk
WHERE
    i_manager_id = 1
    AND (t_hour BETWEEN 7 AND 9 OR t_hour BETWEEN 18 AND 20)
    AND ss_sold_date_sk BETWEEN (SELECT d_date_sk FROM date_dim WHERE d_date = '2001-11-01')
    AND (SELECT d_date_sk FROM date_dim WHERE d_date = '2001-11-30')
GROUP BY
    i_brand,
    i_brand_id,
    sale_hour,
    sale_minute
ORDER BY
    total_sales_revenue DESC,
    i_brand_id;


