-- Test to ensure we have data in the fact table with valid balances
--! returns 0 → pass
SELECT *
FROM {{ ref('fct_ethereum_rewards_daily') }}
WHERE balance_eth_eod IS NULL     
   OR balance_eth_eod <= 0        
