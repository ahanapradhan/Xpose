SELECT 
    ss_item_sk AS item_id,
    i_item_desc AS item_description,
    ss_store_sk AS store_id,
    s_store_name AS store_name,
    MAX(ss_net_profit) AS max_store_sales_net_profit,
    MAX(sr_net_loss) AS max_store_returns_net_loss,
    MAX(cs_net_profit) AS max_catalog_sales_net_profit
FROM
    store_sales
JOIN
    item ON ss_item_sk = i_item_sk
JOIN
    store ON ss_store_sk = s_store_sk
LEFT JOIN
    store_returns ON ss_item_sk = sr_item_sk AND ss_store_sk = sr_store_sk
LEFT JOIN
    catalog_sales ON ss_item_sk = cs_item_sk
WHERE
    ss_sold_date_sk BETWEEN (SELECT d_date_sk FROM date_dim WHERE d_year = 2001 AND d_moy = 4)
    AND (SELECT d_date_sk FROM date_dim WHERE d_year = 2001 AND d_moy = 10)
GROUP BY
    ss_item_sk, i_item_desc, ss_store_sk, s_store_name
ORDER BY
    ss_item_sk, ss_store_sk
LIMIT 100;


