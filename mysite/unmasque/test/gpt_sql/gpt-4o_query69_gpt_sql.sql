SELECT
    c.c_customer_id,
    c.c_gender,
    c.c_marital_status,
    c.c_education_status,
    c.c_purchase_estimate,
    c.c_credit_rating,
    COUNT(*) AS purchase_count
FROM
    store_sales ss
JOIN
    customer c ON ss.ss_customer_sk = c.c_customer_sk
JOIN
    date_dim d ON ss.ss_sold_date_sk = d.d_date_sk
WHERE
    c.c_current_addr_sk IN (
        SELECT ca_address_sk
        FROM customer_address
        WHERE ca_state IN ('KS', 'AZ', 'NE')
    )
    AND d.d_year = 2004
    AND d.d_moy BETWEEN 3 AND 5
    AND c.c_customer_id NOT IN (
        SELECT ws.ws_bill_customer_sk
        FROM web_sales ws
        JOIN date_dim d2 ON ws.ws_sold_date_sk = d2.d_date_sk
        WHERE d2.d_year = 2004 AND d2.d_moy BETWEEN 3 AND 5
        UNION
        SELECT cs.cs_ship_customer_sk
        FROM catalog_sales cs
        JOIN date_dim d3 ON cs.cs_sold_date_sk = d3.d_date_sk
        WHERE d3.d_year = 2004 AND d3.d_moy BETWEEN 3 AND 5
    )
GROUP BY
    c.c_customer_id,
    c.c_gender,
    c.c_marital_status,
    c.c_education_status,
    c.c_purchase_estimate,
    c.c_credit_rating;


