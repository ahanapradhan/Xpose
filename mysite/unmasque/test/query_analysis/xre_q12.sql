Select i_item_id, i_item_desc, Min(i_category) as i_category, i_class, i_current_price, Sum(ws_ext_sales_price) as itemrevenue, 100.0 as revenueratio
 From date_dim, item, web_sales
 Where date_dim.d_date_sk = web_sales.ws_sold_date_sk
 and item.i_item_sk = web_sales.ws_item_sk
 and item.i_category IN ('Home', 'Men', 'Women')
 and date_dim.d_date between '2000-05-11' and '2000-06-10'
 Group By i_class, i_current_price, i_item_desc, i_item_id
 Order By i_category asc, i_class asc, i_item_id asc, i_item_desc asc, itemrevenue asc, i_current_price asc
 Limit 100;