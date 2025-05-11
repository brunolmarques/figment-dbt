-- Test to ensure we have data in the fact table with valid balances
--! returns 0 → pass
select 1
from {{ ref('fct_ethereum_rewards_daily') }}
where balance_eth_eod is not null
  and balance_eth_eod > 0
limit 1