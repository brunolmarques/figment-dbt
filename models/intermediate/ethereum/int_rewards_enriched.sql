{#
──────────────────────────────────────────────────────────────
  INTERMEDIATE - ethereum rewards enriched (optional)
  •  Adds useful analytics columns (running balance, cumulative reward).
  •  Materialised as TABLE - deterministic lookups, reused in many marts.
  •  The math never changes, so table keeps downstream runs fast.
  •  Indexes:
    - validator: equality look-ups in later joins
    - reward_date: helps find reward values by date
    - validator,reward_date: composite for point-in-time balance look-ups
──────────────────────────────────────────────────────────────
#}
{{ config(
    materialized='table',
    tags=['intermediate','ethereum'],
    on_schema_change='append_new_columns',
    indexes = [
      { 'columns': ['validator'] },
      { 'columns': ['reward_date'] },      
      { 'columns': ['validator','reward_date'] }   
    ]
) }}

with base as ( 
    select * from {{ ref('stg_ethereum_rewards') }}
    where reward_eth > 0  -- Only include positive rewards
)

, enriched as (
    select
        *,
        sum(reward_eth) over (
            partition by validator
            order by reward_ts
            rows between unbounded preceding and current row
        ) as cumulative_reward_eth,
        sum(reward_wei) over (
            partition by validator
            order by reward_ts
            rows between unbounded preceding and current row
        ) as cumulative_reward_wei
    from base
)

select * from enriched
