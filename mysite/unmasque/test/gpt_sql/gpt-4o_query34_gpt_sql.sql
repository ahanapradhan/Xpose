SELECT c.c_last_name, 
       c.c_first_name, 
       c.c_salutation, 
       c.c_preferred_cust_flag, 
       ss_ticket_number
FROM store_sales
JOIN customer ON store_sales.ss_customer_sk = customer.c_customer_sk
JOIN store ON store_sales.ss_store_sk = store.s_store_sk
JOIN household_demographics ON customer.c_current_hdemo_sk = household_demographics.hd_demo_sk
WHERE store.s_county = 'Williamson'
  AND store_sales.ss_sold_date_sk IN (
      SELECT d_date_sk
      FROM date_dim
      WHERE d_year BETWEEN 1999 AND 2001
        AND d_dom IN (1, 15, 30) -- Example days of the month
  )
  AND household_demographics.hd_buy_potential = 'High'
  AND household_demographics.hd_vehicle_count > household_demographics.hd_dep_count
GROUP BY c.c_customer_sk, c.c_last_name, c.c_first_name, c.c_salutation, c.c_preferred_cust_flag, ss_ticket_number
HAVING COUNT(ss_ticket_number) BETWEEN 15 AND 20
ORDER BY c.c_last_name DESC, c.c_first_name DESC, c.c_salutation DESC, c.c_preferred_cust_flag DESC;


