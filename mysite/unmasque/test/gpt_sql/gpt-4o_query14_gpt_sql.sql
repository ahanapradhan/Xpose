WITH avg_sales AS (
    SELECT i_item_id, AVG(total_sales) AS avg_sales_value
    FROM (
        SELECT i_item_id, SUM(ss_sales_price) AS total_sales
        FROM store_sales
        JOIN item ON ss_item_sk = i_item_sk
        WHERE ss_sold_date_sk BETWEEN (SELECT d_date_sk FROM date_dim WHERE d_year = 1999 AND d_moy = 1 AND d_dom = 1)
                                  AND (SELECT d_date_sk FROM date_dim WHERE d_year = 2001 AND d_moy = 12 AND d_dom = 31)
        GROUP BY i_item_id
        UNION ALL
        SELECT i_item_id, SUM(cs_sales_price) AS total_sales
        FROM catalog_sales
        JOIN item ON cs_item_sk = i_item_sk
        WHERE cs_sold_date_sk BETWEEN (SELECT d_date_sk FROM date_dim WHERE d_year = 1999 AND d_moy = 1 AND d_dom = 1)
                                  AND (SELECT d_date_sk FROM date_dim WHERE d_year = 2001 AND d_moy = 12 AND d_dom = 31)
        GROUP BY i_item_id
        UNION ALL
        SELECT i_item_id, SUM(ws_sales_price) AS total_sales
        FROM web_sales
        JOIN item ON ws_item_sk = i_item_sk
        WHERE ws_sold_date_sk BETWEEN (SELECT d_date_sk FROM date_dim WHERE d_year = 1999 AND d_moy = 1 AND d_dom = 1)
                                  AND (SELECT d_date_sk FROM date_dim WHERE d_year = 2001 AND d_moy = 12 AND d_dom = 31)
        GROUP BY i_item_id
    ) sales_data
    GROUP BY i_item_id
)
SELECT 'store' AS channel, i_brand, i_class, i_category, SUM(ss_sales_price) AS total_sales, COUNT(*) AS num_transactions
FROM store_sales
JOIN item ON ss_item_sk = i_item_sk
JOIN avg_sales ON i_item_id = avg_sales.i_item_id
WHERE ss_sold_date_sk BETWEEN (SELECT d_date_sk FROM date_dim WHERE d_year = 2001 AND d_moy = 11 AND d_dom = 1)
                          AND (SELECT d_date_sk FROM date_dim WHERE d_year = 2001 AND d_moy = 11 AND d_dom = 30)
AND total_sales > avg_sales_value
GROUP BY i_brand, i_class, i_category
HAVING SUM(ss_sales_price) > avg_sales_value
LIMIT 100
UNION ALL
SELECT 'catalog' AS channel, i_brand, i_class, i_category, SUM(cs_sales_price) AS total_sales, COUNT(*) AS num_transactions
FROM catalog_sales
JOIN item ON cs_item_sk = i_item_sk
JOIN avg_sales ON i_item_id = avg_sales.i_item_id
WHERE cs_sold_date_sk BETWEEN (SELECT d_date_sk FROM date_dim WHERE d_year = 2001 AND d_moy = 11 AND d_dom = 1)
                          AND (SELECT d_date_sk FROM date_dim WHERE d_year = 2001 AND d_moy = 11 AND d_dom = 30)
AND total_sales > avg_sales_value
GROUP BY i_brand, i_class, i_category
HAVING SUM(cs_sales_price) > avg_sales_value
LIMIT 100
UNION ALL
SELECT 'web' AS channel, i_brand, i_class, i_category, SUM(ws_sales_price) AS total_sales, COUNT(*) AS num_transactions
FROM web_sales
JOIN item ON ws_item_sk = i_item_sk
JOIN avg_sales ON i_item_id = avg_sales.i_item_id
WHERE ws_sold_date_sk BETWEEN (SELECT d_date_sk FROM date_dim WHERE d_year = 2001 AND d_moy = 11 AND d_dom = 1)
                          AND (SELECT d_date_sk FROM date_dim WHERE d_year = 2001 AND d_moy = 11 AND d_dom = 30)
AND total_sales > avg_sales_value
GROUP BY i_brand, i_class, i_category
HAVING SUM(ws_sales_price) > avg_sales_value
LIMIT 100;

WITH avg_store_sales AS (
    SELECT i_item_id, AVG(ss_sales_price) AS avg_sales_value
    FROM store_sales
    JOIN item ON ss_item_sk = i_item_sk
    WHERE ss_sold_date_sk BETWEEN (SELECT d_date_sk FROM date_dim WHERE d_year = 1999 AND d_moy = 1 AND d_dom = 1)
                              AND (SELECT d_date_sk FROM date_dim WHERE d_year = 2000 AND d_moy = 12 AND d_dom = 31)
    GROUP BY i_item_id
)
SELECT i_brand, i_class, i_category, SUM(ss_sales_price) AS total_sales, COUNT(*) AS num_transactions
FROM store_sales
JOIN item ON ss_item_sk = i_item_sk
JOIN avg_store_sales ON i_item_id = avg_store_sales.i_item_id
WHERE ss_sold_date_sk BETWEEN (SELECT d_date_sk FROM date_dim WHERE d_year = 2000 AND d_moy = 12 AND d_dom BETWEEN 25 AND 31)
                          OR ss_sold_date_sk BETWEEN (SELECT d_date_sk FROM date_dim WHERE d_year = 1999 AND d_moy = 12 AND d_dom BETWEEN 25 AND 31)
AND total_sales > avg_sales_value
GROUP BY i_brand, i_class, i_category
HAVING SUM(ss_sales_price) > avg_sales_value
ORDER BY i_brand, i_class, i_category
LIMIT 100;


