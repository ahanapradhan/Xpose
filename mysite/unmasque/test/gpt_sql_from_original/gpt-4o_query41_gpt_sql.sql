SELECT COUNT(*) FROM item WHERE (i_color, i_units, i_size, i_category) IN ( ('Red', 'Box', 'Large', 'Electronics'), ('Blue', 'Piece', 'Medium', 'Clothing'), ('Green', 'Pack', 'Small', 'Toys') );
