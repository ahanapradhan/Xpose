SELECT c.c_customer_id, 
       CONCAT(c.c_last_name, ', ', c.c_first_name) AS full_name
FROM customer c
JOIN customer_address ca ON c.c_current_addr_sk = ca.ca_address_sk
JOIN customer_demographics cd ON c.c_current_cdemo_sk = cd.cd_demo_sk
JOIN household_demographics hd ON c.c_current_hdemo_sk = hd.hd_demo_sk
JOIN income_band ib ON hd.hd_income_band_sk = ib.ib_income_band_sk
JOIN store_returns sr ON c.c_customer_sk = sr.sr_customer_sk
WHERE ca.ca_city = 'Green Acres'
  AND ib.ib_lower_bound <= :income_lower_bound
  AND ib.ib_upper_bound >= :income_upper_bound
GROUP BY c.c_customer_id, c.c_last_name, c.c_first_name
ORDER BY c.c_customer_id
LIMIT 100;


