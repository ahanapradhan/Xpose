WITH Top_Customers AS (
    SELECT ss_customer_sk
    FROM store_sales
    GROUP BY ss_customer_sk
    HAVING SUM(ss_net_paid) > 0.95 * (SELECT MAX(total_sales) FROM (SELECT SUM(ss_net_paid) AS total_sales FROM store_sales GROUP BY ss_customer_sk) AS max_sales)
),
Frequently_Sold_Items AS (
    SELECT ss_item_sk
    FROM store_sales
    GROUP BY ss_item_sk
    HAVING COUNT(*) > (SELECT 0.95 * MAX(item_count) FROM (SELECT COUNT(*) AS item_count FROM store_sales GROUP BY ss_item_sk) AS max_items)
)
SELECT SUM(cs_net_paid) AS total_catalog_sales, SUM(ws_net_paid) AS total_web_sales
FROM catalog_sales
JOIN web_sales ON cs_item_sk = ws_item_sk
WHERE cs_sold_date_sk IN (SELECT d_date_sk FROM date_dim WHERE d_year = 1998 AND d_moy = 6)
  AND ws_sold_date_sk IN (SELECT d_date_sk FROM date_dim WHERE d_year = 1998 AND d_moy = 6)
  AND cs_item_sk IN (SELECT ss_item_sk FROM Frequently_Sold_Items)
  AND cs_bill_customer_sk IN (SELECT ss_customer_sk FROM Top_Customers)
  AND ws_bill_customer_sk IN (SELECT ss_customer_sk FROM Top_Customers);

SELECT c_customer_id, c_first_name, c_last_name, SUM(ss_net_paid) AS total_store_sales
FROM store_sales
JOIN customer ON ss_customer_sk = c_customer_sk
WHERE ss_sold_date_sk IN (SELECT d_date_sk FROM date_dim WHERE d_year = 1998 AND d_moy = 6)
  AND ss_customer_sk IN (SELECT ss_customer_sk FROM Top_Customers)
GROUP BY c_customer_id, c_first_name, c_last_name
ORDER BY total_store_sales DESC;


