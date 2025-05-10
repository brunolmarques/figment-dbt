{{-
/*
  Adds useful analytics columns (running balance, cumulative reward).
  Materialised as TABLE – deterministic lookups, reused in many marts.
  The math never changes, so table keeps downstream runs fast.
*/
-}}
{{ config(materialized='table', tags=['intermediate','ethereum']) }}

with base as ( select * from {{ ref('stg_ethereum_rewards') }} )

, enriched as (
    select
        *,
        sum(reward_eth) over (
            partition by validator
            order by reward_ts
            rows between unbounded preceding and current row
        ) as cumulative_reward_eth
    from base
)

select * from enriched
