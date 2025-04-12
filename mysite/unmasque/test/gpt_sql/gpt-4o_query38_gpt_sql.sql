WITH store_customers AS (
    SELECT DISTINCT ss_customer_sk AS customer_sk
    FROM store_sales
    WHERE ss_sold_date_sk BETWEEN (SELECT d_date_sk FROM date_dim WHERE d_date = '2022-01-01')
                              AND (SELECT d_date_sk FROM date_dim WHERE d_date = '2022-12-31')
),
catalog_customers AS (
    SELECT DISTINCT cs_bill_customer_sk AS customer_sk
    FROM catalog_sales
    WHERE cs_sold_date_sk BETWEEN (SELECT d_date_sk FROM date_dim WHERE d_date = '2022-01-01')
                              AND (SELECT d_date_sk FROM date_dim WHERE d_date = '2022-12-31')
),
web_customers AS (
    SELECT DISTINCT ws_bill_customer_sk AS customer_sk
    FROM web_sales
    WHERE ws_sold_date_sk BETWEEN (SELECT d_date_sk FROM date_dim WHERE d_date = '2022-01-01')
                              AND (SELECT d_date_sk FROM date_dim WHERE d_date = '2022-12-31')
)
SELECT COUNT(DISTINCT customer_sk) AS unique_customers
FROM store_customers
INTERSECT
SELECT customer_sk FROM catalog_customers
INTERSECT
SELECT customer_sk FROM web_customers;


