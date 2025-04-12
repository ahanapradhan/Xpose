WITH AverageCategoryPrice AS (
    SELECT i_category, AVG(i_current_price) AS avg_price
    FROM item
    GROUP BY i_category
),
HighPricedSales AS (
    SELECT s_state, COUNT(*) AS transaction_count
    FROM store_sales
    JOIN date_dim ON ss_sold_date_sk = d_date_sk
    JOIN item ON ss_item_sk = i_item_sk
    JOIN store ON ss_store_sk = s_store_sk
    JOIN AverageCategoryPrice ON item.i_category = AverageCategoryPrice.i_category
    WHERE d_year = 1998
      AND d_moy = 7
      AND i_current_price > 1.5 * avg_price
    GROUP BY s_state
    HAVING COUNT(*) >= 10
)
SELECT s_state, transaction_count
FROM HighPricedSales
ORDER BY transaction_count ASC
FETCH FIRST 100 ROWS ONLY;


