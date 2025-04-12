SELECT
    c_customer_sk,
    c_gender,
    c_marital_status,
    c_education_status,
    COUNT(*) AS purchase_count,
    SUM(CASE WHEN c_credit_rating = 'Good' THEN 1 ELSE 0 END) AS good_credit_count,
    SUM(c_dep_count) AS total_dependents,
    SUM(c_employed_dependents) AS employed_dependents,
    SUM(c_college_dependents) AS college_dependents
FROM
    customer
JOIN
    store_sales ON customer.c_customer_sk = store_sales.ss_customer_sk
JOIN
    date_dim ON store_sales.ss_sold_date_sk = date_dim.d_date_sk
JOIN
    store ON store_sales.ss_store_sk = store.s_store_sk
WHERE
    d_year = 2002
    AND d_moy BETWEEN 4 AND 7
    AND s_county IN ('Lycoming', 'Sheridan', 'Kandiyohi', 'Pike', 'Greene')
GROUP BY
    c_customer_sk,
    c_gender,
    c_marital_status,
    c_education_status
ORDER BY
    c_gender,
    c_marital_status,
    c_education_status,
    purchase_count DESC
LIMIT 100;


