SELECT c.c_last_name, 
       c.c_first_name, 
       c.c_salutation, 
       c.c_preferred_cust_flag, 
       sst.ss_ticket_number
FROM customer c
JOIN store_sales sst ON c.c_customer_sk = sst.ss_customer_sk
JOIN store st ON sst.ss_store_sk = st.s_store_sk
JOIN household_demographics hd ON c.c_current_hdemo_sk = hd.hd_demo_sk
JOIN customer_demographics cd ON c.c_current_cdemo_sk = cd.cd_demo_sk
JOIN date_dim dd ON sst.ss_sold_date_sk = dd.d_date_sk
WHERE st.s_county = 'Williamson County'
  AND dd.d_year IN (2000, 2001, 2002)
  AND dd.d_dom IN (1, 2)
  AND hd.hd_vehicle_count > 0
  AND (cd.cd_purchase_estimate = 'high' OR cd.cd_purchase_estimate = 'low')
GROUP BY c.c_customer_sk, c.c_last_name, c.c_first_name, c.c_salutation, c.c_preferred_cust_flag, sst.ss_ticket_number
HAVING COUNT(sst.ss_ticket_number) BETWEEN 1 AND 5
ORDER BY COUNT(sst.ss_ticket_number) DESC, c.c_last_name ASC;


