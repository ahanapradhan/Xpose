SELECT
    d_year,
    i_brand,
    i_brand_id,
    SUM(ss_ext_sales_price) AS total_sales_revenue
FROM
    store_sales
JOIN
    date_dim ON store_sales.ss_sold_date_sk = date_dim.d_date_sk
JOIN
    item ON store_sales.ss_item_sk = item.i_item_sk
JOIN
    store ON store_sales.ss_store_sk = store.s_store_sk
WHERE
    d_year = 1999
    AND d_moy = 11
    AND s_manager_id = 1
GROUP BY
    d_year,
    i_brand,
    i_brand_id
ORDER BY
    d_year,
    total_sales_revenue DESC,
    i_brand_id
LIMIT 100;


