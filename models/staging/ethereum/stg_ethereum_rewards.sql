{{ config(
     pre_hook = "{{ log_step('Start staging ethereum_rewards') }}",
     post_hook = "{{ log_step('Finished staging ethereum_rewards') }}"
) }}

with src as (
    select *
    from {{ source('ethereum', 'ethereum_rewards_raw') }}
)

select
    {{ sanitize_numeric('claimed_reward_numeric', 'claimed_reward_exp') }}     as reward_eth,
    lower(trim(validator))                                                   as validator,
    {{ dbt.safe_cast("block", "bigint") }}                                   as block,
    {{ dbt_date.day_timestamp("timestamp") }}                                as ts_day,
    *
from src;