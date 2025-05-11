{#
  ──────────────────────────────────────────────────────────────
  STAGING - ethereum rewards
  •  One-to-one with sources.ethereum_rewards_raw
  •  Cleans types, enforces domain values, explodes exponent,
     and generates helper keys for later joins/aggregations.
  •  Materialized as TABLE (immutable, deterministic, tiny).
  •  Indexes:
    - validator: equality look-ups in later joins
    - mark: helps find mark values in the data
  ──────────────────────────────────────────────────────────────
#}
{{ config(
    materialized='table',
    tags=['staging','ethereum'],
    on_schema_change='append_new_columns',
    indexes = [
      { 'columns': ['validator'] },                
      { 'columns': ['mark']   , 'type': 'brin' }   
    ]
) }}

with src as (

    select *
    from {{ source('ethereum', 'ethereum_rewards_raw') }}

), cleaned as (

    select
        -- == business columns ===========================================================
        lower(trim(network))                                                as network,
        lower(trim(protocol))                                               as protocol,
        lower(trim(reward_type))                                            as reward_type,
        lower(trim(address))                                                as validator,
        mark::bigint                                                        as mark,
        lower(trim(claimed_reward_currency))                                as currency,
        -- reward value normalised to wei (numeric(38,0))
        {{ reward_wei('claimed_reward_numeric', 'claimed_reward_exp') }}    as reward_wei,
        -- reward value normalised to ETH (numeric(38,18))
        {{ reward_wei('claimed_reward_numeric', 'claimed_reward_exp') }} 
                / 1e18::numeric(38,18)                                      as reward_eth,
        timestamp::timestamptz                                              as reward_ts,
        date_trunc('day', timestamp::timestamptz)                           as reward_date,

        -- == metadata ===================================================================
        processed_at::timestamptz                                           as processed_at,
        {{ dbt_utils.generate_surrogate_key([
            'address',
            'reward_type',
            'mark::text'
        ]) }}                                                  as sk
    from src
    where lower(type) = 'rewards'        -- defensive filter
        and claimed_reward_numeric is not null
), deduped as (
    select distinct on (validator, reward_type, mark) *
    from cleaned
    order by validator, reward_type, mark, processed_at desc
)

select * from deduped
