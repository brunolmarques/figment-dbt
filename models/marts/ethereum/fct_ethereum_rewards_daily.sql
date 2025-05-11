-- Purpose Incremental daily snapshot with a running balance per validator.
{#
──────────────────────────────────────────────────────────────
MART - ethereum rewards daily 
  •  FACT TABLE: one row per validator-day-reward_type
  •  Incremental strategy: only add the *previous* day once 
    the date is fully closed to guarantee "end-of-period" accuracy.
  • unique_key keeps Postgres from duplicating rows if 
    the model is re-executed during a CI pipeline.
  •  on_schema_change = 'append_new_columns' adds extra 
    measures for schema enforcement/evolution.
  •  Indexes:
    - validator: local to each date partition
    - reward_type: helps find reward values by type
    - reward_date: global BRIN for multiple days scans
    - validator,reward_date: satisfies WHERE validator=? AND 
        reward_date BETWEEN … without re-checking partitions.
──────────────────────────────────────────────────────────────
#}

{{ config(
     materialized = 'incremental',
     unique_key   = ['validator','reward_type','reward_date'],
     on_schema_change = 'append_new_columns',
     tags = ['mart','ethereum'],
     indexes = [
      { 'columns': ['validator'] },                       
      { 'columns': ['reward_type'] },
      { 'columns': ['reward_date']   , 'type': 'brin' },   
      { 'columns': ['validator','reward_date'] }          
    ]
) }}

with src as (                        -- 1. yesterday’s daily totals
    select
        validator,
        reward_type,
        reward_date,
        daily_reward_eth,
        daily_reward_wei
    from {{ ref('int_rewards_daily_agg') }}
    {% if is_incremental() %}
      where reward_date = (current_date - interval '1 day')::date
    {% endif %}
)

select                               -- 2. dbt will wrap this SELECT in its own INSERT
    s.validator,
    s.reward_type,
    s.reward_date,
    /* reward for the day */
    s.daily_reward_eth                               as reward_eth,
    s.daily_reward_wei                               as reward_wei,

    /* running balance = yesterday’s EoD + today’s reward */
    coalesce(p.balance_eth_eod, 0) + s.daily_reward_eth  as balance_eth_eod,
    coalesce(p.balance_wei_eod, 0) + s.daily_reward_wei  as balance_wei_eod
from   src s
left   join {{ this }} p
       on  p.validator    = s.validator
       and p.reward_type  = s.reward_type
       and p.reward_date  = s.reward_date - interval '1 day'