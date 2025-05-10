-- Purpose Incremental daily snapshot with a running balance per validator.
{{-
/*
  FACT TABLE: one row per validator-day-reward_type
  Incremental strategy: “insert_by_period” – only add the *previous* day
  once the date is fully closed to guarantee “end-of-period” accuracy.
  - insert_overwrite + date partition → idempotent re-runs and late-arriving data are harmless (always fully overwrite the affected day).
  - unique_key keeps Postgres from duplicating rows if the model is re-executed during a CI pipeline.
  - on_schema_change = 'sync_all_columns' adds extra measures for schema enforcement/evolution, remove need to run `dbt run --full-refresh`.
*/
-}}
{% set yest = dbt_date.today_back(1,'day') %}

{{ config(
     materialized = 'incremental',
     unique_key   = ['validator','reward_type','reward_date'],
     partition_by = {'field': 'reward_date', 'data_type': 'date'},
     incremental_strategy = 'insert_overwrite',
     on_schema_change = 'sync_all_columns',
     tags = ['mart','ethereum']
) }}

with src as (

    select *
    from {{ ref('int_rewards_daily_agg') }}
    {% if is_incremental() %}
        where reward_date = {{ yest }}
    {% endif %}

)

select
    validator,
    reward_type,
    reward_date,
    daily_reward_eth                        as reward_eth,
    sum(daily_reward_eth)
        over (partition by validator order by reward_date)     as balance_eth_eod
from src
