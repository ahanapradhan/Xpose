WITH ProfitRankings AS (
    SELECT
        i_item_sk,
        i_item_desc,
        AVG(ss_net_profit) AS avg_net_profit,
        RANK() OVER (ORDER BY AVG(ss_net_profit) DESC) AS rank_desc,
        RANK() OVER (ORDER BY AVG(ss_net_profit) ASC) AS rank_asc
    FROM
        store_sales
    JOIN
        item ON ss_item_sk = i_item_sk
    WHERE
        ss_store_sk = 4
    GROUP BY
        i_item_sk, i_item_desc
),
TopBestWorst AS (
    SELECT
        i_item_sk,
        i_item_desc,
        avg_net_profit,
        rank_desc,
        rank_asc
    FROM
        ProfitRankings
    WHERE
        rank_desc <= 10 OR rank_asc <= 10
)
SELECT
    i_item_desc,
    avg_net_profit,
    rank_desc,
    rank_asc
FROM
    TopBestWorst
ORDER BY
    rank_desc ASC, rank_asc ASC
LIMIT 100;


