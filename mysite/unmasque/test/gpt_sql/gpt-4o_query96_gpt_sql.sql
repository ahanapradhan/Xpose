SELECT COUNT(*) AS transaction_count
FROM store_sales ss
JOIN store s ON ss.ss_store_sk = s.s_store_sk
JOIN household_demographics hd ON ss.ss_hdemo_sk = hd.hd_demo_sk
WHERE s.s_store_name = 'ese'
  AND ss.ss_sold_time BETWEEN 1230 AND 1259
  AND hd.hd_dep_count = 7
GROUP BY s.s_store_name
ORDER BY transaction_count DESC
LIMIT 100;


