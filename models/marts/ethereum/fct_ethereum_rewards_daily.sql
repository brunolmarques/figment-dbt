{{ config(materialized='incremental', on_schema_change='append_new_columns') }}

with staging as (
    select
        validator,
        date_trunc('day', timestamp) as date,
        sum(reward_eth)             as daily_reward_eth,
        max(processed_at)           as updated_at   -- for merge freshness
    from {{ ref('int_ethereum_rewards') }}
    {% if is_incremental() %}
      where timestamp >= (select dateadd('day', -1, max(date)) from {{ this }})
    {% endif %}
    group by 1,2
)

{{ incremental_merge(this, ["validator","date"], "updated_at") }}