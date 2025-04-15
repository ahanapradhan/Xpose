SELECT ca.ca_county, ca.ca_state, COUNT(cs.cs_order_number) AS number_of_orders, SUM(cs.cs_ext_ship_cost) AS total_shipping_costs, SUM(cs.cs_net_profit) AS total_profits FROM catalog_sales cs JOIN customer_address ca ON cs.cs_ship_addr_sk = ca.ca_address_sk JOIN date_dim dd ON cs.cs_sold_date_sk = dd.d_date_sk LEFT JOIN catalog_returns cr ON cs.cs_order_number = cr.cr_order_number WHERE cr.cr_order_number IS NULL AND cs.cs_warehouse_sk IS NOT NULL AND dd.d_date BETWEEN CURRENT_DATE - INTERVAL '60 days' AND CURRENT_DATE GROUP BY ca.ca_county, ca.ca_state;
