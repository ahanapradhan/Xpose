WITH ss AS (
  SELECT
    s_store_sk,
    SUM(ss_ext_sales_price) AS sales,
    SUM(ss_net_profit) AS profit
  FROM store_sales
  JOIN date_dim ON ss_sold_date_sk = d_date_sk
  JOIN store ON ss_store_sk = s_store_sk
  WHERE d_date BETWEEN DATE '2001-08-16' AND DATE '2001-08-16' + INTERVAL '30 days'
  GROUP BY s_store_sk
),
sr AS (
  SELECT
    s_store_sk,
    SUM(sr_return_amt) AS returns1,
    SUM(sr_net_loss) AS profit_loss
  FROM store_returns
  JOIN date_dim ON sr_returned_date_sk = d_date_sk
  JOIN store ON sr_store_sk = s_store_sk
  WHERE d_date BETWEEN DATE '2001-08-16' AND DATE '2001-08-16' + INTERVAL '30 days'
  GROUP BY s_store_sk
),
cs AS (
  SELECT
    cs_call_center_sk,
    SUM(cs_ext_sales_price) AS sales,
    SUM(cs_net_profit) AS profit
  FROM catalog_sales
  JOIN date_dim ON cs_sold_date_sk = d_date_sk
  WHERE d_date BETWEEN DATE '2001-08-16' AND DATE '2001-08-16' + INTERVAL '30 days'
  GROUP BY cs_call_center_sk
),
cr AS (
  SELECT
    cr_call_center_sk,
    SUM(cr_return_amount) AS returns1,
    SUM(cr_net_loss) AS profit_loss
  FROM catalog_returns
  JOIN date_dim ON cr_returned_date_sk = d_date_sk
  WHERE d_date BETWEEN DATE '2001-08-16' AND DATE '2001-08-16' + INTERVAL '30 days'
  GROUP BY cr_call_center_sk
),
ws AS (
  SELECT
    wp_web_page_sk,
    SUM(ws_ext_sales_price) AS sales,
    SUM(ws_net_profit) AS profit
  FROM web_sales
  JOIN date_dim ON ws_sold_date_sk = d_date_sk
  JOIN web_page ON ws_web_page_sk = wp_web_page_sk
  WHERE d_date BETWEEN DATE '2001-08-16' AND DATE '2001-08-16' + INTERVAL '30 days'
  GROUP BY wp_web_page_sk
),
wr AS (
  SELECT
    wp_web_page_sk,
    SUM(wr_return_amt) AS returns1,
    SUM(wr_net_loss) AS profit_loss
  FROM web_returns
  JOIN date_dim ON wr_returned_date_sk = d_date_sk
  JOIN web_page ON wr_web_page_sk = wp_web_page_sk
  WHERE d_date BETWEEN DATE '2001-08-16' AND DATE '2001-08-16' + INTERVAL '30 days'
  GROUP BY wp_web_page_sk
)

SELECT
  channel,
  id,
  SUM(sales) AS sales,
  SUM(returns1) AS returns1,
  SUM(profit) AS profit
FROM (
  SELECT
    'store channel' AS channel,
    ss.s_store_sk AS id,
    ss.sales,
    COALESCE(sr.returns1, 0) AS returns1,
    ss.profit - COALESCE(sr.profit_loss, 0) AS profit
  FROM ss
  LEFT JOIN sr ON ss.s_store_sk = sr.s_store_sk

  UNION ALL

  SELECT
    'catalog channel' AS channel,
    cs.cs_call_center_sk AS id,
    cs.sales,
    COALESCE(cr.returns1, 0) AS returns1,
    cs.profit - COALESCE(cr.profit_loss, 0) AS profit
  FROM cs
  LEFT JOIN cr ON cs.cs_call_center_sk = cr.cr_call_center_sk

  UNION ALL

  SELECT
    'web channel' AS channel,
    ws.wp_web_page_sk AS id,
    ws.sales,
    COALESCE(wr.returns1, 0) AS returns1,
    ws.profit - COALESCE(wr.profit_loss, 0) AS profit
  FROM ws
  LEFT JOIN wr ON ws.wp_web_page_sk = wr.wp_web_page_sk
) AS x
GROUP BY ROLLUP (channel, id)
ORDER BY channel, id
LIMIT 100;
