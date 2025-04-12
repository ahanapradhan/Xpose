SELECT 
    i_item_id,
    i_item_desc,
    s_store_id,
    s_store_name,
    SUM(ss_ext_sales_price) AS total_sales,
    SUM(CASE WHEN p_channel IN ('Direct Mail', 'Email', 'TV') THEN ss_ext_sales_price ELSE 0 END) AS promo_sales,
    (SUM(CASE WHEN p_channel IN ('Direct Mail', 'Email', 'TV') THEN ss_ext_sales_price ELSE 0 END) / SUM(ss_ext_sales_price)) * 100 AS promo_sales_percentage
FROM
    store_sales
JOIN
    store ON ss_store_sk = s_store_sk
JOIN
    promotion ON ss_promo_sk = p_promo_sk
JOIN
    date_dim ON ss_sold_date_sk = d_date_sk
JOIN
    customer ON ss_customer_sk = c_customer_sk
JOIN
    customer_address ON c_current_addr_sk = ca_address_sk
JOIN
    item ON ss_item_sk = i_item_sk
WHERE
    d_year = 2001
    AND d_moy = 12
    AND s_gmt_offset = -7
GROUP BY
    i_item_id, i_item_desc, s_store_id, s_store_name
ORDER BY
    promo_sales DESC, total_sales DESC
LIMIT 100;


