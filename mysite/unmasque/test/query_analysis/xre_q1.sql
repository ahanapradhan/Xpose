Select c_customer_id
 From customer, date_dim, store, store_returns sr, store_returns sr1
 Where customer.c_customer_sk = sr.sr_customer_sk
 and date_dim.d_date_sk = sr.sr_returned_date_sk
 and sr.sr_returned_date_sk = sr1.sr_returned_date_sk
 and store.s_store_sk = sr.sr_store_sk
 and sr.sr_store_sk = sr1.sr_store_sk
 and sr1.sr_return_amt*1.2 < sr.sr_return_amt
 and date_dim.d_year = 2001
 and store.s_state = 'TN'
 Order By c_customer_id asc;

 -- Remove the bogus predicates which you invalidated, and the rewrite the query by matching the text.

 SELECT DISTINCT c.c_customer_id
FROM customer c
JOIN store_returns sr ON c.c_customer_sk = sr.sr_customer_sk
JOIN store s ON sr.sr_store_sk = s.s_store_sk
JOIN date_dim d ON sr.sr_returned_date_sk = d.d_date_sk
WHERE s.s_state = 'TN'
  AND d.d_year = 2001
GROUP BY c.c_customer_id, sr.sr_store_sk
HAVING COUNT(*) > (
    SELECT AVG(return_count) * 1.2
    FROM (
        SELECT COUNT(*) AS return_count
        FROM store_returns sr_sub
        JOIN store s_sub ON sr_sub.sr_store_sk = s_sub.s_store_sk
        JOIN date_dim d_sub ON sr_sub.sr_returned_date_sk = d_sub.d_date_sk
        WHERE s_sub.s_state = 'TN'
          AND d_sub.d_year = 2001
        GROUP BY sr_sub.sr_customer_sk, sr_sub.sr_store_sk
    ) AS avg_returns
);

-- this give 1256 rows.
-- if count(*) is replaced with sum(sr_return_amt), then it gives 956 rows.

SELECT DISTINCT c.c_customer_id
FROM customer c
JOIN store_returns sr ON c.c_customer_sk = sr.sr_customer_sk
JOIN store s ON sr.sr_store_sk = s.s_store_sk
JOIN date_dim d ON sr.sr_returned_date_sk = d.d_date_sk
WHERE s.s_state = 'TN'
  AND d.d_year = 2001
GROUP BY c.c_customer_id, sr.sr_store_sk
HAVING SUM(sr.sr_return_amt) > (
    SELECT AVG(customer_amt) * 1.2
    FROM (
        SELECT sr_sub.sr_store_sk, sr_sub.sr_customer_sk, SUM(sr_sub.sr_return_amt) AS customer_amt
        FROM store_returns sr_sub
        JOIN store s_sub ON sr_sub.sr_store_sk = s_sub.s_store_sk
        JOIN date_dim d_sub ON sr_sub.sr_returned_date_sk = d_sub.d_date_sk
        WHERE s_sub.s_state = 'TN'
          AND d_sub.d_year = 2001
        GROUP BY sr_sub.sr_store_sk, sr_sub.sr_customer_sk
    ) AS per_customer_avg
    WHERE per_customer_avg.sr_store_sk = sr.sr_store_sk
)
ORDER BY c.c_customer_id;

