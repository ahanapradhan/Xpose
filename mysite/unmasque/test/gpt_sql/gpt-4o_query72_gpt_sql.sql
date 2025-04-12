SELECT 
    i_item_desc,
    w_warehouse_name,
    d_week_seq,
    COUNT(cs_sold_date_sk) AS total_sales,
    SUM(CASE WHEN cs_promo_sk IS NOT NULL THEN 1 ELSE 0 END) AS sales_with_promo,
    SUM(CASE WHEN cs_promo_sk IS NULL THEN 1 ELSE 0 END) AS sales_without_promo
FROM
    catalog_sales
JOIN
    customer ON cs_bill_customer_sk = c_customer_sk
JOIN
    household_demographics ON c_current_hdemo_sk = hd_demo_sk
JOIN
    item ON cs_item_sk = i_item_sk
JOIN
    warehouse ON cs_warehouse_sk = w_warehouse_sk
JOIN
    date_dim ON cs_sold_date_sk = d_date_sk
JOIN
    inventory ON cs_item_sk = inv_item_sk AND cs_warehouse_sk = inv_warehouse_sk
WHERE
    c_marital_status = 'M'
    AND hd_buy_potential BETWEEN '$501' AND '$1000'
    AND d_year = 2002
    AND inv_quantity_on_hand < cs_quantity
    AND d_date > DATE_ADD(cs_sold_date, INTERVAL 5 DAY)
GROUP BY
    i_item_desc, w_warehouse_name, d_week_seq
ORDER BY
    total_sales DESC
LIMIT 100;


