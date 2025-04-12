SELECT
    c.c_customer_zip AS customer_zip,
    c.c_customer_state AS customer_state,
    SUM(ws.ws_ext_sales_price) AS total_sales_revenue
FROM
    web_sales ws
JOIN
    customer c ON ws.ws_bill_customer_sk = c.c_customer_sk
JOIN
    item i ON ws.ws_item_sk = i.i_item_sk
WHERE
    (c.c_customer_zip IN ('ZIP_CODE_1', 'ZIP_CODE_2', 'ZIP_CODE_3')) -- Replace with actual zip codes
    OR (i.i_item_id IN ('ITEM_ID_1', 'ITEM_ID_2', 'ITEM_ID_3')) -- Replace with actual item IDs
    AND ws.ws_sold_date_sk BETWEEN (SELECT d_date_sk FROM date_dim WHERE d_year = 2000 AND d_moy = 1 AND d_dom = 1)
    AND (SELECT d_date_sk FROM date_dim WHERE d_year = 2000 AND d_moy = 3 AND d_dom = 31)
GROUP BY
    c.c_customer_zip,
    c.c_customer_state
ORDER BY
    c.c_customer_zip,
    c.c_customer_state
LIMIT 100;


