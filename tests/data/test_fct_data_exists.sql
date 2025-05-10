-- Test to ensure we have data in the fact table with valid balances
with f as (
    select * from {{ ref('fct_ethereum_rewards_daily') }}
)
select count(*) as row_count
from f
where f.balance_eth_eod is not null 
  and f.balance_eth_eod > 0 