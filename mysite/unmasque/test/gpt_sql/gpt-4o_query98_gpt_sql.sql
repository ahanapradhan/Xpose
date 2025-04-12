SELECT 
    i_item_id,
    i_item_desc,
    i_category,
    i_class,
    i_current_price,
    SUM(ss_ext_sales_price) AS total_revenue,
    SUM(ss_ext_sales_price) / SUM(SUM(ss_ext_sales_price)) OVER (PARTITION BY i_category, i_class) AS revenue_ratio
FROM
    store_sales
JOIN
    item ON ss_item_sk = i_item_sk
WHERE
    i_category IN ('Men', 'Home', 'Electronics')
    AND ss_sold_date_sk BETWEEN 
        (SELECT d_date_sk FROM date_dim WHERE d_date = '2000-05-18') 
        AND 
        (SELECT d_date_sk FROM date_dim WHERE d_date = '2000-06-16')
GROUP BY
    i_item_id,
    i_item_desc,
    i_category,
    i_class,
    i_current_price
ORDER BY
    i_category,
    i_class,
    i_item_id,
    i_item_desc,
    revenue_ratio DESC;


