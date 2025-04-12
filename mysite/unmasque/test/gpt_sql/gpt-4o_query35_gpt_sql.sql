WITH customer_demographics AS (
    SELECT
        c_customer_id,
        c_state,
        c_gender,
        c_marital_status,
        c_dep_count,
        c_dep_employed_count,
        c_dep_college_count
    FROM customer
),
sales_data AS (
    SELECT
        ss_customer_sk AS customer_sk,
        ss_sold_date_sk AS sold_date_sk,
        'store' AS channel
    FROM store_sales
    UNION ALL
    SELECT
        ws_bill_customer_sk AS customer_sk,
        ws_sold_date_sk AS sold_date_sk,
        'web' AS channel
    FROM web_sales
    UNION ALL
    SELECT
        cs_bill_customer_sk AS customer_sk,
        cs_sold_date_sk AS sold_date_sk,
        'catalog' AS channel
    FROM catalog_sales
),
filtered_sales AS (
    SELECT
        sd.customer_sk,
        sd.channel
    FROM sales_data sd
    JOIN date_dim dd ON sd.sold_date_sk = dd.d_date_sk
    WHERE dd.d_year = 2001 AND dd.d_moy <= 9
)
SELECT
    cd.c_state,
    cd.c_gender,
    cd.c_marital_status,
    cd.c_dep_count,
    cd.c_dep_employed_count,
    cd.c_dep_college_count,
    COUNT(*) AS purchase_count,
    STDDEV_POP(cd.c_dep_count) AS dep_count_stddev,
    AVG(cd.c_dep_count) AS avg_dep_count,
    MAX(cd.c_dep_count) AS max_dep_count
FROM customer_demographics cd
JOIN filtered_sales fs ON cd.c_customer_id = fs.customer_sk
GROUP BY
    cd.c_state,
    cd.c_gender,
    cd.c_marital_status,
    cd.c_dep_count,
    cd.c_dep_employed_count,
    cd.c_dep_college_count
ORDER BY purchase_count DESC
LIMIT 100;


