WITH AverageNetProfit AS (
    SELECT AVG(ss_net_paid) * 0.05 AS threshold
    FROM store_sales
),
CustomerNetProfit AS (
    SELECT 
        ss_customer_sk,
        ss_store_sk,
        SUM(ss_net_paid) AS total_net_profit
    FROM 
        store_sales
    JOIN item ON ss_item_sk = i_item_sk
    WHERE 
        i_color IN ('papaya', 'chartreuse')
        AND ss_store_sk IN (
            SELECT s_store_sk
            FROM store
            WHERE s_market_id = 6
        )
    GROUP BY 
        ss_customer_sk, ss_store_sk
)
SELECT 
    ss_customer_sk,
    ss_store_sk,
    total_net_profit
FROM 
    CustomerNetProfit, AverageNetProfit
WHERE 
    total_net_profit > threshold;


