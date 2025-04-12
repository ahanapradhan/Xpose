WITH avg_state_return AS (
    SELECT sr_customer_sk, AVG(sr_return_amt + sr_return_tax) * 1.2 AS threshold
    FROM store_returns
    JOIN date_dim ON sr_returned_date_sk = d_date_sk
    WHERE d_year = 1999
    GROUP BY sr_customer_sk
),
customer_returns AS (
    SELECT c_customer_sk, c_first_name, c_last_name, c_address_sk, 
           ca_address, ca_city, ca_state, ca_zip, 
           SUM(sr_return_amt + sr_return_tax) AS total_return_amt
    FROM store_returns
    JOIN date_dim ON sr_returned_date_sk = d_date_sk
    JOIN customer ON sr_customer_sk = c_customer_sk
    JOIN customer_address ON c_address_sk = ca_address_sk
    WHERE d_year = 1999 AND ca_state = 'TX'
    GROUP BY c_customer_sk, c_first_name, c_last_name, c_address_sk, 
             ca_address, ca_city, ca_state, ca_zip
)
SELECT c_customer_sk, c_first_name, c_last_name, ca_address, ca_city, ca_state, ca_zip, total_return_amt
FROM customer_returns
JOIN avg_state_return ON customer_returns.c_customer_sk = avg_state_return.sr_customer_sk
WHERE total_return_amt > avg_state_return.threshold
ORDER BY c_customer_sk, c_first_name, c_last_name
LIMIT 100;


