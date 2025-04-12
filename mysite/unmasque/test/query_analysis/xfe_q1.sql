WITH customer_returns AS (
    SELECT
        sr.sr_store_sk,
        sr.sr_customer_sk,
        COUNT(*) AS return_count
    FROM store_returns sr
    JOIN store s ON sr.sr_store_sk = s.s_store_sk
    JOIN date_dim d ON sr.sr_returned_date_sk = d.d_date_sk
    WHERE s.s_state = 'TN'        -- Given state
      AND d.d_year = 2001         -- Given year
      AND sr.sr_customer_sk IS NOT NULL
    GROUP BY sr.sr_store_sk, sr.sr_customer_sk
),

store_avg_returns AS (
    SELECT
        sr_store_sk,
        AVG(return_count) AS avg_return_count
    FROM customer_returns
    GROUP BY sr_store_sk
)

SELECT DISTINCT c.c_customer_id
FROM customer_returns cr
JOIN store_avg_returns sar
  ON cr.sr_store_sk = sar.sr_store_sk
JOIN customer c
  ON cr.sr_customer_sk = c.c_customer_sk
WHERE cr.return_count > sar.avg_return_count * 1.2;

--- 1259 rows. Best after 5-6 rounds of prompting.
-- asked to think step by step.
-- now it keeps repeating this query.


-- identification of one CTE is correct
-- same CTE is used for avg aggregate on top of it --> correct
-- both are used in JOIN --> correct
-- algebraic comparison with 1.2 factor --> correct