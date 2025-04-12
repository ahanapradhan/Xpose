WITH sales_data AS (
    SELECT
        p.p_manufact_id AS manufacturer_id,
        SUM(ss.ss_ext_sales_price) AS total_store_sales,
        SUM(cs.cs_ext_sales_price) AS total_catalog_sales,
        SUM(ws.ws_ext_sales_price) AS total_web_sales
    FROM
        store_sales ss
    JOIN
        item i ON ss.ss_item_sk = i.i_item_sk
    JOIN
        product p ON i.i_product_id = p.p_product_id
    JOIN
        date_dim d ON ss.ss_sold_date_sk = d.d_date_sk
    JOIN
        customer c ON ss.ss_customer_sk = c.c_customer_sk
    WHERE
        d.d_year = 1999
        AND d.d_moy = 3
        AND c.c_current_gmt_offset = -5
    GROUP BY
        p.p_manufact_id

    UNION ALL

    SELECT
        p.p_manufact_id AS manufacturer_id,
        SUM(ss.ss_ext_sales_price) AS total_store_sales,
        SUM(cs.cs_ext_sales_price) AS total_catalog_sales,
        SUM(ws.ws_ext_sales_price) AS total_web_sales
    FROM
        catalog_sales cs
    JOIN
        item i ON cs.cs_item_sk = i.i_item_sk
    JOIN
        product p ON i.i_product_id = p.p_product_id
    JOIN
        date_dim d ON cs.cs_sold_date_sk = d.d_date_sk
    JOIN
        customer c ON cs.cs_bill_customer_sk = c.c_customer_sk
    WHERE
        d.d_year = 1999
        AND d.d_moy = 3
        AND c.c_current_gmt_offset = -5
    GROUP BY
        p.p_manufact_id

    UNION ALL

    SELECT
        p.p_manufact_id AS manufacturer_id,
        SUM(ss.ss_ext_sales_price) AS total_store_sales,
        SUM(cs.cs_ext_sales_price) AS total_catalog_sales,
        SUM(ws.ws_ext_sales_price) AS total_web_sales
    FROM
        web_sales ws
    JOIN
        item i ON ws.ws_item_sk = i.i_item_sk
    JOIN
        product p ON i.i_product_id = p.p_product_id
    JOIN
        date_dim d ON ws.ws_sold_date_sk = d.d_date_sk
    JOIN
        customer c ON ws.ws_bill_customer_sk = c.c_customer_sk
    WHERE
        d.d_year = 1999
        AND d.d_moy = 3
        AND c.c_current_gmt_offset = -5
    GROUP BY
        p.p_manufact_id
)

SELECT
    manufacturer_id,
    SUM(total_store_sales) AS total_store_sales,
    SUM(total_catalog_sales) AS total_catalog_sales,
    SUM(total_web_sales) AS total_web_sales,
    (SUM(total_store_sales) + SUM(total_catalog_sales) + SUM(total_web_sales)) AS total_sales
FROM
    sales_data
GROUP BY
    manufacturer_id
ORDER BY
    total_sales DESC
LIMIT 100;


