WITH store_customers AS (
    SELECT DISTINCT c_customer_id
    FROM store_sales
    WHERE ss_sold_date_sk BETWEEN (SELECT d_date_sk FROM date_dim WHERE d_date = '2022-01-01')
                              AND (SELECT d_date_sk FROM date_dim WHERE d_date = '2022-12-31')
),
catalog_customers AS (
    SELECT DISTINCT c_customer_id
    FROM catalog_sales
    WHERE cs_sold_date_sk BETWEEN (SELECT d_date_sk FROM date_dim WHERE d_date = '2022-01-01')
                              AND (SELECT d_date_sk FROM date_dim WHERE d_date = '2022-12-31')
)
SELECT 
    COUNT(DISTINCT sc.c_customer_id) AS store_only_customers,
    COUNT(DISTINCT cc.c_customer_id) AS catalog_only_customers,
    COUNT(DISTINCT both.c_customer_id) AS both_channels_customers
FROM 
    (SELECT c_customer_id FROM store_customers
     EXCEPT
     SELECT c_customer_id FROM catalog_customers) sc
FULL OUTER JOIN 
    (SELECT c_customer_id FROM catalog_customers
     EXCEPT
     SELECT c_customer_id FROM store_customers) cc
ON sc.c_customer_id = cc.c_customer_id
FULL OUTER JOIN 
    (SELECT c_customer_id FROM store_customers
     INTERSECT
     SELECT c_customer_id FROM catalog_customers) both
ON sc.c_customer_id = both.c_customer_id OR cc.c_customer_id = both.c_customer_id;


