WITH sales_data AS (
    SELECT i_item_id, SUM(ss_ext_sales_price) AS total_sales
    FROM store_sales
    JOIN item ON ss_item_sk = i_item_sk
    JOIN date_dim ON ss_sold_date_sk = d_date_sk
    WHERE i_color IN ('firebrick', 'rosy', 'white')
      AND d_year = 1998
      AND d_moy = 3
      AND d_gmt_offset = -6
    GROUP BY i_item_id

    UNION ALL

    SELECT i_item_id, SUM(cs_ext_sales_price) AS total_sales
    FROM catalog_sales
    JOIN item ON cs_item_sk = i_item_sk
    JOIN date_dim ON cs_sold_date_sk = d_date_sk
    WHERE i_color IN ('firebrick', 'rosy', 'white')
      AND d_year = 1998
      AND d_moy = 3
      AND d_gmt_offset = -6
    GROUP BY i_item_id

    UNION ALL

    SELECT i_item_id, SUM(ws_ext_sales_price) AS total_sales
    FROM web_sales
    JOIN item ON ws_item_sk = i_item_sk
    JOIN date_dim ON ws_sold_date_sk = d_date_sk
    WHERE i_color IN ('firebrick', 'rosy', 'white')
      AND d_year = 1998
      AND d_moy = 3
      AND d_gmt_offset = -6
    GROUP BY i_item_id
)

SELECT i_item_id, SUM(total_sales) AS total_sales
FROM sales_data
GROUP BY i_item_id
ORDER BY total_sales DESC
LIMIT 100;


