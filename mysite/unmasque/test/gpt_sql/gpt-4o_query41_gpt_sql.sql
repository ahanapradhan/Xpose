SELECT DISTINCT i_item_desc AS product_name
FROM item
WHERE i_manufact_id BETWEEN 765 AND 805
  AND i_category IN ('Women', 'Men')
  AND (
    (i_color = 'Red' AND i_units = 'Piece' AND i_size = 'M') OR
    (i_color = 'Blue' AND i_units = 'Pack' AND i_size = 'L') OR
    (i_color = 'Green' AND i_units = 'Box' AND i_size = 'S')
  )
ORDER BY i_item_desc
LIMIT 100;


