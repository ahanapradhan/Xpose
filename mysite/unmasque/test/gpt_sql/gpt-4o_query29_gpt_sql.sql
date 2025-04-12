SELECT 
    i_item_id,
    i_item_desc,
    s_store_id,
    s_store_name,
    AVG(ss_quantity) AS avg_store_sales_quantity,
    AVG(sr_return_quantity) AS avg_store_return_quantity,
    AVG(cs_quantity) AS avg_catalog_sales_quantity
FROM
    store_sales
JOIN
    item ON store_sales.ss_item_sk = item.i_item_sk
JOIN
    store ON store_sales.ss_store_sk = store.s_store_sk
LEFT JOIN
    store_returns ON store_sales.ss_ticket_number = store_returns.sr_ticket_number
                  AND store_sales.ss_item_sk = store_returns.sr_item_sk
LEFT JOIN
    catalog_sales ON store_sales.ss_item_sk = catalog_sales.cs_item_sk
WHERE
    ss_sold_date_sk BETWEEN (SELECT d_date_sk FROM date_dim WHERE d_date = '1998-04-01')
                        AND (SELECT d_date_sk FROM date_dim WHERE d_date = '1998-04-30')
GROUP BY
    i_item_id, i_item_desc, s_store_id, s_store_name
ORDER BY
    i_item_id, i_item_desc, s_store_id, s_store_name
LIMIT 100;


