WITH AverageDiscount AS (
    SELECT AVG(ws_discount_amt) * 1.3 AS threshold_discount
    FROM web_sales
    WHERE ws_sold_date_sk BETWEEN 
        (SELECT d_date_sk FROM date_dim WHERE d_date = '2002-03-29') AND 
        (SELECT d_date_sk FROM date_dim WHERE d_date = '2002-06-26')
),
ExcessDiscounts AS (
    SELECT ws_item_sk, SUM(ws_discount_amt) - SUM(ws_quantity) * ad.threshold_discount AS excess_discount
    FROM web_sales ws
    JOIN item i ON ws.ws_item_sk = i.i_item_sk
    CROSS JOIN AverageDiscount ad
    WHERE i.i_manufact_id = 718
      AND ws_sold_date_sk BETWEEN 
          (SELECT d_date_sk FROM date_dim WHERE d_date = '2002-03-29') AND 
          (SELECT d_date_sk FROM date_dim WHERE d_date = '2002-06-26')
    GROUP BY ws_item_sk
    HAVING SUM(ws_discount_amt) > SUM(ws_quantity) * ad.threshold_discount
)
SELECT ws_item_sk, excess_discount
FROM ExcessDiscounts
ORDER BY excess_discount DESC
LIMIT 100;


