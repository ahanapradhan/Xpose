SELECT 
    i.i_category,
    i.i_class,
    i.i_brand,
    s.s_store_name,
    s.s_company_name,
    SUM(ss.ss_sales_price) AS total_sales,
    AVG(ss.ss_sales_price) * 12 AS avg_monthly_sales,
    ABS(SUM(ss.ss_sales_price) - (AVG(ss.ss_sales_price) * 12)) AS sales_difference
FROM 
    store_sales ss
JOIN 
    item i ON ss.ss_item_sk = i.i_item_sk
JOIN 
    store s ON ss.ss_store_sk = s.s_store_sk
WHERE 
    ss.ss_sold_date_sk BETWEEN (SELECT d_date_sk FROM date_dim WHERE d_year = 2002 AND d_moy = 1 AND d_dom = 1)
    AND (SELECT d_date_sk FROM date_dim WHERE d_year = 2002 AND d_moy = 12 AND d_dom = 31)
GROUP BY 
    i.i_category, i.i_class, i.i_brand, s.s_store_name, s.s_company_name
HAVING 
    ABS(SUM(ss.ss_sales_price) - (AVG(ss.ss_sales_price) * 12)) > (0.1 * (AVG(ss.ss_sales_price) * 12))
ORDER BY 
    sales_difference DESC, s.s_store_name
LIMIT 100;


