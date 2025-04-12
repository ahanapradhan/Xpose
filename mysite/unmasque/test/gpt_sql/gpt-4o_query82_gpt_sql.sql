SELECT i_item_id, i_item_desc, i_current_price
FROM item
JOIN inventory ON i_item_id = inv_item_id
JOIN date_dim ON inv_date_sk = d_date_sk
WHERE i_current_price BETWEEN 63 AND 93
  AND i_manufact_id IN (57, 293, 427, 320)
  AND inv_quantity_on_hand BETWEEN 100 AND 500
  AND d_date BETWEEN '1998-04-27' AND '1998-06-25'
GROUP BY i_item_id, i_item_desc, i_current_price
ORDER BY i_item_id
LIMIT 100;


