WITH PreferredCustomerAreas AS (
    SELECT SUBSTRING(c_zip, 1, 2) AS zip_prefix
    FROM customer
    GROUP BY SUBSTRING(c_zip, 1, 2)
    HAVING COUNT(*) > 10
),
StoreNetProfit AS (
    SELECT
        s_store_name,
        SUM(ss_net_profit) AS total_net_profit
    FROM
        store_sales
    JOIN
        store ON store.s_store_sk = store_sales.ss_store_sk
    JOIN
        date_dim ON store_sales.ss_sold_date_sk = date_dim.d_date_sk
    WHERE
        d_year = 2000
        AND d_moy BETWEEN 4 AND 6
        AND SUBSTRING(s_zip, 1, 2) IN (SELECT zip_prefix FROM PreferredCustomerAreas)
    GROUP BY
        s_store_name
)
SELECT
    s_store_name
FROM
    StoreNetProfit
ORDER BY
    total_net_profit DESC,
    s_store_name
LIMIT 100;


