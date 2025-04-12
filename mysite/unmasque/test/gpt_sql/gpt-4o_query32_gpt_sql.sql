WITH AverageDiscount AS (
    SELECT
        cs_item_sk,
        AVG(cs_ext_discount_amt) * 1.3 AS threshold_discount
    FROM
        catalog_sales
    WHERE
        cs_sold_date_sk BETWEEN (SELECT d_date_sk FROM date_dim WHERE d_date = '2001-03-04')
        AND (SELECT d_date_sk FROM date_dim WHERE d_date = '2001-06-02')
    GROUP BY
        cs_item_sk
),
ExcessDiscounts AS (
    SELECT
        cs.cs_order_number,
        cs.cs_item_sk,
        cs.cs_ext_discount_amt,
        ad.threshold_discount
    FROM
        catalog_sales cs
    JOIN
        item i ON cs.cs_item_sk = i.i_item_sk
    JOIN
        AverageDiscount ad ON cs.cs_item_sk = ad.cs_item_sk
    WHERE
        i.i_manufact_id = 610
        AND cs.cs_sold_date_sk BETWEEN (SELECT d_date_sk FROM date_dim WHERE d_date = '2001-03-04')
        AND (SELECT d_date_sk FROM date_dim WHERE d_date = '2001-06-02')
        AND cs.cs_ext_discount_amt > ad.threshold_discount
)
SELECT
    cs_order_number,
    cs_item_sk,
    cs_ext_discount_amt,
    threshold_discount
FROM
    ExcessDiscounts
ORDER BY
    cs_ext_discount_amt DESC
LIMIT 100;


