SELECT 
    i_brand_id,
    i_brand,
    i_manufact_id,
    i_manufact,
    SUM(ss_ext_sales_price) AS total_sales_revenue
FROM
    store_sales
JOIN
    item ON store_sales.ss_item_sk = item.i_item_sk
JOIN
    customer ON store_sales.ss_customer_sk = customer.c_customer_sk
JOIN
    store ON store_sales.ss_store_sk = store.s_store_sk
JOIN
    date_dim ON store_sales.ss_sold_date_sk = date_dim.d_date_sk
WHERE
    date_dim.d_year = 1998
    AND date_dim.d_moy = 12
    AND store.s_manager = 38
    AND SUBSTRING(customer.c_current_addr_sk, 1, 5) <> SUBSTRING(store.s_zip, 1, 5)
GROUP BY
    i_brand_id, i_brand, i_manufact_id, i_manufact
ORDER BY
    total_sales_revenue DESC
LIMIT 100;


