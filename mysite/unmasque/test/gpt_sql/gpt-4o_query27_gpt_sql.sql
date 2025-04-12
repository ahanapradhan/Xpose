SELECT 
    i_item_id,
    s_state,
    AVG(ss_quantity) AS avg_quantity_sold,
    AVG(ss_list_price) AS avg_list_price,
    AVG(ss_coupon_amt) AS avg_coupon_amount,
    AVG(ss_sales_price) AS avg_sales_price
FROM
    store_sales
JOIN
    store ON ss_store_sk = s_store_sk
JOIN
    item ON ss_item_sk = i_item_sk
JOIN
    customer ON ss_customer_sk = c_customer_sk
JOIN
    customer_demographics ON c_current_cdemo_sk = cd_demo_sk
WHERE
    s_state = 'TN'
    AND ss_sold_date_sk BETWEEN (SELECT d_date_sk FROM date_dim WHERE d_year = 2000 AND d_moy = 1 AND d_dom = 1)
    AND (SELECT d_date_sk FROM date_dim WHERE d_year = 2000 AND d_moy = 12 AND d_dom = 31)
    AND cd_gender = 'M'
    AND cd_marital_status = 'D'
    AND cd_education_status = 'College'
GROUP BY
    ROLLUP(i_item_id, s_state)
ORDER BY
    i_item_id,
    s_state
LIMIT 100;


