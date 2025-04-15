SELECT i_product_name, i_brand, i_class, i_category, AVG(inv_quantity_on_hand) AS avg_quantity_on_hand FROM inventory JOIN item ON inventory.inv_item_sk = item.i_item_sk GROUP BY ROLLUP(i_product_name, i_brand, i_class, i_category);
