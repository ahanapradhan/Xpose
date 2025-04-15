SELECT c.c_last_name, c.c_first_name, ca.ca_city AS current_city, sa.ca_city AS purchase_city, ss.ss_ticket_number, ss.ss_coupon_amt, ss.ss_net_profit FROM store_sales ss JOIN customer c ON ss.ss_customer_sk = c.c_customer_sk JOIN customer_address ca ON c.c_current_addr_sk = ca.ca_address_sk JOIN customer_address sa ON ss.ss_addr_sk = sa.ca_address_sk JOIN date_dim d ON ss.ss_sold_date_sk = d.d_date_sk JOIN household_demographics hd ON ss.ss_hdemo_sk = hd.hd_demo_sk WHERE ca.ca_city <> sa.ca_city AND d.d_year IN (2000, 2001, 2002) AND d.d_dow IN (6, 7) AND sa.ca_city IN ('Midway', 'Fairview') AND (hd.hd_dep_count = 6 OR hd.hd_vehicle_count = 0) ORDER BY c.c_last_name, c.c_first_name, current_city, purchase_city, ss.ss_ticket_number LIMIT 100;
