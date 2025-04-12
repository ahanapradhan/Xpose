WITH average_store_returns AS (
    SELECT sr_store_id, AVG(sr_return_amt) * 1.2 AS threshold
    FROM store_returns
    WHERE EXTRACT(YEAR FROM sr_returned_date) = 2001
    GROUP BY sr_store_id
),
customer_returns AS (
    SELECT sr_customer_id, sr_store_id, SUM(sr_return_amt) AS total_return_amt
    FROM store_returns
    WHERE EXTRACT(YEAR FROM sr_returned_date) = 2001
    GROUP BY sr_customer_id, sr_store_id
),
qualified_customers AS (
    SELECT cr.sr_customer_id
    FROM customer_returns cr
    JOIN average_store_returns ar ON cr.sr_store_id = ar.sr_store_id
    WHERE cr.total_return_amt > ar.threshold
),
tennessee_customers AS (
    SELECT c_customer_id
    FROM customer
    WHERE c_state = 'TN'
)
SELECT qc.sr_customer_id
FROM qualified_customers qc
JOIN tennessee_customers tc ON qc.sr_customer_id = tc.c_customer_id
LIMIT 100;

