SELECT 
    w.w_warehouse_name,
    i.i_item_id,
    SUM(CASE WHEN d.d_date < '2000-05-13' THEN inv.inv_quantity_on_hand ELSE 0 END) AS inventory_before,
    SUM(CASE WHEN d.d_date >= '2000-05-13' THEN inv.inv_quantity_on_hand ELSE 0 END) AS inventory_after
FROM
    inventory inv
JOIN
    item i ON inv.inv_item_sk = i.i_item_sk
JOIN
    warehouse w ON inv.inv_warehouse_sk = w.w_warehouse_sk
JOIN
    date_dim d ON inv.inv_date_sk = d.d_date_sk
WHERE
    i.i_current_price BETWEEN 0.99 AND 1.49
    AND d.d_date BETWEEN DATE '2000-04-13' AND DATE '2000-06-12'
GROUP BY
    w.w_warehouse_name, i.i_item_id
HAVING
    inventory_after / NULLIF(inventory_before, 0) BETWEEN 2.0/3.0 AND 1.5
ORDER BY
    w.w_warehouse_name, i.i_item_id
LIMIT 100;


