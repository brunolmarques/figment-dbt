{#
  Daily totals per validator + reward_type. It is possible to collapse reward_type if the business only needs per-validator totals.
  Materialised as VIEW (stateless) – the heavy incremental work is moved to the mart.
#}
{{ config(materialized='view', tags=['intermediate','ethereum']) }}

select
    validator,
    reward_type,
    reward_date,
    coalesce(sum(reward_eth), 0)              as daily_reward_eth,
    coalesce(sum(reward_wei),  0)             as daily_reward_wei
from {{ ref('stg_ethereum_rewards') }}
group by 1,2,3
