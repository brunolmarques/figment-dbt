--! returns 0 → pass. non-zero rows are failures.
with latest_day as (
  select max(reward_date) as d from {{ ref('fct_ethereum_rewards_daily') }}
)
select count(*) as num_bad
from {{ ref('fct_ethereum_rewards_daily') }} f
join latest_day l on f.reward_date = l.d
where f.balance_eth_eod is null;
