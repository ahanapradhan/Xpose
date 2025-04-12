SELECT ss_customer_sk AS customer_id,
       SUM(ss_net_paid - COALESCE(sr_return_amt, 0)) AS total_actual_sales
FROM store_sales
LEFT JOIN store_returns ON ss_item_sk = sr_item_sk AND ss_ticket_number = sr_ticket_number
WHERE sr_reason_sk = 38 OR sr_reason_sk IS NULL
GROUP BY ss_customer_sk
ORDER BY total_actual_sales DESC, customer_id
LIMIT 100;


