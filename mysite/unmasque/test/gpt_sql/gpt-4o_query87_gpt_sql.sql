SELECT COUNT(DISTINCT ss_customer_sk) AS unique_customers
FROM store_sales
WHERE ss_sold_date_sk BETWEEN (SELECT d_date_sk FROM date_dim WHERE d_date = 'YYYY-MM-DD') 
                          AND (SELECT d_date_sk FROM date_dim WHERE d_date = 'YYYY-MM-DD' + INTERVAL '1 year' - INTERVAL '1 day')
AND ss_customer_sk NOT IN (
    SELECT cs_bill_customer_sk
    FROM catalog_sales
    WHERE cs_sold_date_sk BETWEEN (SELECT d_date_sk FROM date_dim WHERE d_date = 'YYYY-MM-DD') 
                              AND (SELECT d_date_sk FROM date_dim WHERE d_date = 'YYYY-MM-DD' + INTERVAL '1 year' - INTERVAL '1 day')
    UNION
    SELECT ws_bill_customer_sk
    FROM web_sales
    WHERE ws_sold_date_sk BETWEEN (SELECT d_date_sk FROM date_dim WHERE d_date = 'YYYY-MM-DD') 
                              AND (SELECT d_date_sk FROM date_dim WHERE d_date = 'YYYY-MM-DD' + INTERVAL '1 year' - INTERVAL '1 day')
);

Replace `'YYYY-MM-DD'` with the start date of the one-year period you are interested in.


