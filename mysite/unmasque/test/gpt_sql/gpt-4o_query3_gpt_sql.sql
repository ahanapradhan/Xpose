SELECT
    EXTRACT(YEAR FROM ss_sold_date_sk) AS year,
    i_brand_id,
    i_brand,
    SUM(ss_ext_discount_amt) AS total_discount
FROM
    store_sales
JOIN
    item ON store_sales.ss_item_sk = item.i_item_sk
WHERE
    i_manufact_id = 427
    AND EXTRACT(MONTH FROM ss_sold_date_sk) = 11
GROUP BY
    year,
    i_brand_id,
    i_brand
ORDER BY
    year,
    total_discount DESC
LIMIT 100;


