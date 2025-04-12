SELECT 
    p_product_name,
    p_brand,
    p_class,
    p_category,
    AVG(inv_quantity_on_hand) AS avg_quantity_on_hand
FROM
    inventory
JOIN
    date_dim ON inv_date_sk = d_date_sk
JOIN
    product ON inv_product_sk = p_product_sk
WHERE
    d_date BETWEEN DATE_SUB(CURRENT_DATE, INTERVAL 12 MONTH) AND CURRENT_DATE
GROUP BY
    ROLLUP(p_product_name, p_brand, p_class, p_category)
ORDER BY
    avg_quantity_on_hand DESC,
    p_product_name,
    p_brand,
    p_class,
    p_category
LIMIT 100;


