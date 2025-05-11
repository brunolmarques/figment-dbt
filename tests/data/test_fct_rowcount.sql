-- Test that verifies the freshest partition in fct_ethereum_rewards_daily is fully populated with end-of-day balances
--! returns 0 → pass
WITH latest_day AS (
    SELECT MAX(reward_date) AS d
    FROM {{ ref('fct_ethereum_rewards_daily') }}
)
SELECT *
FROM   {{ ref('fct_ethereum_rewards_daily') }} AS f
JOIN   latest_day                              AS l
      ON f.reward_date = l.d
WHERE  f.balance_eth_eod IS NULL
   OR  f.balance_eth_eod <= 0

