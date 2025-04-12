WITH May_2000_Customers AS (
    SELECT DISTINCT c_customer_id
    FROM catalog_sales
    JOIN item ON cs_item_sk = i_item_sk
    WHERE i_category = 'Sports' AND i_class = 'Fitness'
    AND cs_sold_date_sk IN (
        SELECT d_date_sk
        FROM date_dim
        WHERE d_year = 2000 AND d_moy = 5
    )
    UNION
    SELECT DISTINCT c_customer_id
    FROM web_sales
    JOIN item ON ws_item_sk = i_item_sk
    WHERE i_category = 'Sports' AND i_class = 'Fitness'
    AND ws_sold_date_sk IN (
        SELECT d_date_sk
        FROM date_dim
        WHERE d_year = 2000 AND d_moy = 5
    )
),
Customer_Revenue AS (
    SELECT c.c_customer_id, SUM(ss_ext_sales_price) AS total_revenue
    FROM store_sales ss
    JOIN customer c ON ss.ss_customer_sk = c.c_customer_sk
    JOIN store s ON ss.ss_store_sk = s.s_store_sk
    WHERE ss_sold_date_sk IN (
        SELECT d_date_sk
        FROM date_dim
        WHERE (d_year = 2000 AND d_moy BETWEEN 6 AND 8)
    )
    AND s.s_zip = c.c_current_cdemo_sk
    AND c.c_customer_id IN (SELECT c_customer_id FROM May_2000_Customers)
    GROUP BY c.c_customer_id
),
Revenue_Segments AS (
    SELECT FLOOR(total_revenue / 50) * 50 AS revenue_segment, COUNT(*) AS customer_count
    FROM Customer_Revenue
    GROUP BY FLOOR(total_revenue / 50) * 50
)
SELECT revenue_segment, customer_count
FROM Revenue_Segments
ORDER BY revenue_segment;


