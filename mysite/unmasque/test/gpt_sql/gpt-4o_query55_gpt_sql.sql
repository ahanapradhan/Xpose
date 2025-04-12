SELECT 
    i_brand_id, 
    i_brand, 
    SUM(ss_ext_sales_price) AS total_sales_revenue
FROM 
    store_sales
JOIN 
    item ON store_sales.ss_item_sk = item.i_item_sk
JOIN 
    date_dim ON store_sales.ss_sold_date_sk = date_dim.d_date_sk
WHERE 
    d_month = 12 
    AND d_year = 1998 
    AND i_manager_id = 33
GROUP BY 
    i_brand_id, 
    i_brand
ORDER BY 
    total_sales_revenue DESC
LIMIT 100;


