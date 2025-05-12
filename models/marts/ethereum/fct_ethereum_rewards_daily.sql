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
     incremental_strategy = 'delete+insert',
     on_schema_change = 'append_new_columns',
     tags = ['mart','ethereum'],
     indexes = [
      { 'columns': ['validator'] },                       
      { 'columns': ['reward_type'] },
      { 'columns': ['reward_date']   , 'type': 'brin' },   
      { 'columns': ['validator','reward_date'] }          
    ]
) }}

with src as (
     select *
     from {{ ref('int_rewards_daily_agg') }}
     {% if is_incremental() %}
       where reward_date = (current_date - interval '1 day')::date   -- yesterday
     {% endif %}

 )


select
    validator,
    reward_type,
     reward_date,
     daily_reward_eth                        as reward_eth,
     sum(daily_reward_eth)
         over (partition by validator, reward_type order by reward_date)     as balance_eth_eod,
     daily_reward_wei                        as reward_wei,
     sum(daily_reward_wei)
         over (partition by validator, reward_type order by reward_date)     as balance_wei_eod
 from src