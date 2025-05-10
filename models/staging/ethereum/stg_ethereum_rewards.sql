{#
  ──────────────────────────────────────────────────────────────
  STAGING - ethereum rewards
  •  One-to-one with sources.ethereum_rewards_raw
  •  Cleans types, enforces domain values, explodes exponent,
     and generates helper keys for later joins/aggregations.
  •  Materialized as TABLE (immutable, deterministic, tiny).
  ──────────────────────────────────────────────────────────────
#}
{{ config(
    materialized='table',
    tags=['staging','ethereum'],
    on_schema_change='append_new_columns'
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
        lower(trim(validator))                                              as validator,
        block::bigint                                                       as block_id,
        -- reward value normalised to wei (numeric(38,0))
        {{ reward_wei('claimed_reward_numeric', 'claimed_reward_exp') }}    as reward_wei,
        -- reward value normalised to ETH (numeric(38,18))
        {{ reward_wei('claimed_reward_numeric', 'claimed_reward_exp') }} 
            / 1e18::numeric(38,18)                                          as reward_eth,
        timestamp                                                           as reward_ts,
        date_trunc('day', timestamp)                                        as reward_date,

        -- == metadata ===================================================================
        processed_at,
        -- "mark" field in the brief
        {{ dbt_utils.generate_surrogate_key([
            'validator',
            'reward_type',
            'block::text'
        ]) }}                                                  as sk
    from src
    where lower(type) = 'rewards'        -- defensive filter
)

select * from cleaned
