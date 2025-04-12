SELECT 
    i_item_id,
    AVG(ss_quantity) AS avg_quantity_sold,
    AVG(ss_list_price) AS avg_list_price,
    AVG(ss_coupon_amt) AS avg_coupon_amount,
    AVG(ss_sales_price) AS avg_sales_price
FROM
    store_sales
JOIN
    customer ON ss_customer_sk = c_customer_sk
JOIN
    item ON ss_item_sk = i_item_sk
JOIN
    date_dim ON ss_sold_date_sk = d_date_sk
WHERE
    d_year = 1998
    AND c_current_cdemo_sk IN (
        SELECT cd_demo_sk
        FROM customer_demographics
        WHERE cd_gender = 'F'
        AND cd_marital_status = 'W'
        AND cd_education_status = '2 yr Degree'
    )
    AND ss_promo_sk IS NULL
GROUP BY
    i_item_id
ORDER BY
    i_item_id
LIMIT 100;


