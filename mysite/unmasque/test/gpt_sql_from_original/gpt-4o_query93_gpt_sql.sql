SELECT c.c_customer_id, SUM(cs.cs_net_paid) - COALESCE(SUM(cr.cr_return_amount), 0) AS total_net_cost FROM customer c JOIN catalog_sales cs ON c.c_customer_sk = cs.cs_bill_customer_sk LEFT JOIN catalog_returns cr ON cs.cs_order_number = cr.cr_order_number AND cr.cr_reason_sk = (SELECT r_reason_sk FROM reason WHERE r_reason_id = 'reason 28') GROUP BY c.c_customer_id;
