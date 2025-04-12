WITH RankedRegions AS (
    SELECT
        ss_state,
        ss_county,
        SUM(ss_net_profit) AS total_net_profit,
        RANK() OVER (PARTITION BY ss_state ORDER BY SUM(ss_net_profit) DESC) AS county_rank,
        RANK() OVER (ORDER BY SUM(ss_net_profit) DESC) AS state_rank
    FROM
        store_sales
    WHERE
        ss_sold_date BETWEEN DATE '2022-01-01' AND DATE '2022-12-31'
    GROUP BY
        ss_state, ss_county
)
SELECT
    ss_state,
    ss_county,
    total_net_profit,
    county_rank,
    state_rank
FROM
    RankedRegions
ORDER BY
    state_rank, county_rank
FETCH FIRST 100 ROWS ONLY;


