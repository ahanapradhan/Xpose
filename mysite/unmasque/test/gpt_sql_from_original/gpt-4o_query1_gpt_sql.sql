SELECT c.c_customer_id FROM customer c JOIN store_returns sr ON c.c_customer_sk = sr.sr_customer_sk JOIN date_dim d ON sr.sr_returned_date_sk = d.d_date_sk JOIN customer_address ca ON c.c_current_addr_sk = ca.ca_address_sk WHERE ca.ca_state = 'CA' AND d.d_year = 2022 GROUP BY c.c_customer_id HAVING COUNT(sr.sr_return_quantity) > 1.2 * ( SELECT AVG(return_count) FROM ( SELECT COUNT(sr_inner.sr_return_quantity) AS return_count FROM store_returns sr_inner JOIN customer c_inner ON sr_inner.sr_customer_sk = c_inner.c_customer_sk JOIN date_dim d_inner ON sr_inner.sr_returned_date_sk = d_inner.d_date_sk JOIN customer_address ca_inner ON c_inner.c_current_addr_sk = ca_inner.ca_address_sk WHERE ca_inner.ca_state = 'CA' AND d_inner.d_year = 2022 GROUP BY c_inner.c_customer_id ) avg_returns );
