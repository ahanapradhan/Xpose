(Select 'catalog channel' as channel, cp_catalog_page_id as id, Sum(cs_ext_sales_price) as sales, 0.0 as returns1, Sum(cs_net_profit) as profit
 From catalog_page, catalog_sales, date_dim
 Where catalog_sales.cs_sold_date_sk = date_dim.d_date_sk
 and catalog_page.cp_catalog_page_sk = catalog_sales.cs_catalog_page_sk
 and date_dim.d_date between '2002-08-22' and '2002-09-05'
 Group By cp_catalog_page_id
 Order By channel asc, id asc)
 UNION ALL
 (Select 'store channel' as channel, s_store_id as id, Sum(ss_ext_sales_price) as sales, 0.0 as returns1, Sum(ss_net_profit) as profit
 From date_dim, store, store_sales
 Where date_dim.d_date_sk = store_sales.ss_sold_date_sk
 and store.s_store_sk = store_sales.ss_store_sk
 and date_dim.d_date between '2002-08-22' and '2002-09-05'
 Group By s_store_id
 Order By channel asc, id asc)
 UNION ALL
 (Select 'web channel' as channel, web_site_id as id, Sum(ws_ext_sales_price) as sales, 0.0 as returns1, Sum(ws_net_profit) as profit
 From date_dim, web_sales, web_site
 Where date_dim.d_date_sk = web_sales.ws_sold_date_sk
 and web_sales.ws_web_site_sk = web_site.web_site_sk
 and date_dim.d_date between '2002-08-22' and '2002-09-05'
 Group By web_site_id
 Order By channel asc, id asc)
 UNION ALL
 (Select 'catalog channel' as channel, cp_catalog_page_id as id, 0.0 as sales, Sum(cr_return_amount) as returns1, Sum(-cr_net_loss) as profit
 From catalog_page, catalog_returns, date_dim
 Where catalog_page.cp_catalog_page_sk = catalog_returns.cr_catalog_page_sk
 and catalog_returns.cr_returned_date_sk = date_dim.d_date_sk
 and date_dim.d_date between '2002-08-22' and '2002-09-05'
 Group By cp_catalog_page_id
 Order By channel asc, id asc)
 UNION ALL
 (Select 'store channel' as channel, s_store_id as id, 0.0 as sales, Sum(sr_return_amt) as returns1, Sum(-sr_net_loss) as profit
 From date_dim, store, store_returns
 Where date_dim.d_date_sk = store_returns.sr_returned_date_sk
 and store.s_store_sk = store_returns.sr_store_sk
 and date_dim.d_date between '2002-08-22' and '2002-09-05'
 Group By s_store_id
 Order By channel asc, id asc);



 -- xfe-refined
 SELECT
    channel,
    id,
    SUM(sales) AS sales,
    SUM(returns1) AS returns,
    SUM(profit) AS profit
FROM (
    SELECT
        'catalog channel' AS channel,
        cp_catalog_page_id AS id,
        SUM(cs_ext_sales_price) AS sales,
        0.0 AS returns1,
        SUM(cs_net_profit) AS profit
    FROM
        catalog_page
        JOIN catalog_sales ON cp_catalog_page_sk = cs_catalog_page_sk
        JOIN date_dim ON cs_sold_date_sk = d_date_sk
    WHERE
        d_date BETWEEN '2002-08-22' AND '2002-09-05'
    GROUP BY cp_catalog_page_id

    UNION ALL

    SELECT
        'store channel' AS channel,
        s_store_id AS id,
        SUM(ss_ext_sales_price) AS sales,
        0.0 AS returns1,
        SUM(ss_net_profit) AS profit
    FROM
        store
        JOIN store_sales ON s_store_sk = ss_store_sk
        JOIN date_dim ON ss_sold_date_sk = d_date_sk
    WHERE
        d_date BETWEEN '2002-08-22' AND '2002-09-05'
    GROUP BY s_store_id

    UNION ALL

    SELECT
        'web channel' AS channel,
        web_site_id AS id,
        SUM(ws_ext_sales_price) AS sales,
        0.0 AS returns1,
        SUM(ws_net_profit) AS profit
    FROM
        web_site
        JOIN web_sales ON ws_web_site_sk = web_site_sk
        JOIN date_dim ON ws_sold_date_sk = d_date_sk
    WHERE
        d_date BETWEEN '2002-08-22' AND '2002-09-05'
    GROUP BY web_site_id

    UNION ALL

    SELECT
        'catalog channel' AS channel,
        cp_catalog_page_id AS id,
        0.0 AS sales,
        SUM(cr_return_amount) AS returns1,
        SUM(-cr_net_loss) AS profit
    FROM
        catalog_page
        JOIN catalog_returns ON cp_catalog_page_sk = cr_catalog_page_sk
        JOIN date_dim ON cr_returned_date_sk = d_date_sk
    WHERE
        d_date BETWEEN '2002-08-22' AND '2002-09-05'
    GROUP BY cp_catalog_page_id

    UNION ALL

    SELECT
        'store channel' AS channel,
        s_store_id AS id,
        0.0 AS sales,
        SUM(sr_return_amt) AS returns1,
        SUM(-sr_net_loss) AS profit
    FROM
        store
        JOIN store_returns ON s_store_sk = sr_store_sk
        JOIN date_dim ON sr_returned_date_sk = d_date_sk
    WHERE
        d_date BETWEEN '2002-08-22' AND '2002-09-05'
    GROUP BY s_store_id
) AS unified_data
GROUP BY channel, id
ORDER BY channel ASC, id ASC;


-- derived business logic
This report shows how each sales channel—catalog, store, and web—performed over a two-week period from August 22 to September 5, 2002. For every catalog page, physical store, and website, it adds up the total sales revenue, the amount of money lost due to customer returns, and the overall profit. Profit is calculated by taking the income from sales and subtracting the losses from any returns. The result is a clear, channel-by-channel breakdown that helps you see where revenue is coming from, how much is being lost to returns, and which areas are most profitable. This helps managers identify strong performers, spot problem areas, and make more informed decisions about sales strategy and resource allocation.

Cosine Similarity (Sentence-BERT): 0.890
