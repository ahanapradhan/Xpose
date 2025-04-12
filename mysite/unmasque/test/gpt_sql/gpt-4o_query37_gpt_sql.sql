SELECT i_item_id, i_item_desc, i_current_price
FROM item
JOIN inventory ON i_item_id = inv_item_id
WHERE i_current_price BETWEEN 20 AND 50
  AND inv_quantity_on_hand BETWEEN 100 AND 500
  AND inv_date BETWEEN DATE '1999-03-06' AND DATE '1999-05-04'
  AND i_manufact_id IN (843, 815, 850, 840)
GROUP BY i_item_id, i_item_desc, i_current_price
ORDER BY i_item_id
FETCH FIRST 100 ROWS ONLY;


