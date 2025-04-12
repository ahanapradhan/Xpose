SELECT 
    i_item_id,
    AVG(ss_quantity) AS avg_quantity_sold,
    AVG(ss_list_price) AS avg_list_price,
    AVG(ss_coupon_amt) AS avg_coupon_amt,
    AVG(ss_sales_price) AS avg_sales_price
FROM
    store_sales
JOIN
    customer ON ss_customer_sk = c_customer_sk
JOIN
    customer_demographics ON c_current_cdemo_sk = cd_demo_sk
JOIN
    promotion ON ss_promo_sk = p_promo_sk
JOIN
    item ON ss_item_sk = i_item_sk
WHERE
    c_birth_year = 2000
    AND cd_gender = 'F'
    AND cd_marital_status = 'W'
    AND cd_education_status = 'Secondary'
    AND p_channel_email = 'N'
    AND p_channel_event = 'N'
GROUP BY
    i_item_id
ORDER BY
    i_item_id ASC
LIMIT 100;


