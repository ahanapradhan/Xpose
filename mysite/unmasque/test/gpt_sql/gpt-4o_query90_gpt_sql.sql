SELECT 
    wsr.web_sales_afternoon / NULLIF(wsr.web_sales_evening, 0) AS sales_ratio
FROM (
    SELECT 
        SUM(CASE WHEN EXTRACT(HOUR FROM ws_sold_time) = 12 THEN 1 ELSE 0 END) AS web_sales_afternoon,
        SUM(CASE WHEN EXTRACT(HOUR FROM ws_sold_time) = 20 THEN 1 ELSE 0 END) AS web_sales_evening
    FROM 
        web_sales
    JOIN 
        household_demographics ON ws_bill_customer_sk = hd_demo_sk
    JOIN 
        web_page ON ws_web_page_sk = wp_web_page_sk
    WHERE 
        hd_dep_count = 8
        AND wp_char_count BETWEEN 5000 AND 5200
) wsr
ORDER BY 
    sales_ratio DESC
LIMIT 100;


