SELECT sr_customer_sk AS customer_id FROM store_returns JOIN date_dim ON sr_returned_date_sk = d_date_sk JOIN customer_address ON sr_addr_sk = ca_address_sk WHERE d_year = 2001 AND ca_state = 'TN' GROUP BY sr_customer_sk, sr_store_sk HAVING SUM(sr_return_amt) > 1.2 * ( SELECT AVG(sr_return_amt) FROM store_returns sr2 WHERE sr2.sr_store_sk = store_returns.sr_store_sk ) ORDER BY SUM(sr_return_amt) DESC LIMIT 100;
