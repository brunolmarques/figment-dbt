{{-
/*
  ──────────────────────────────────────────────────────────────
  STAGING - ethereum rewards
  •  One-to-one with sources.ethereum_rewards_raw
  •  Cleans types, enforces domain values, explodes exponent,
     and generates helper keys for later joins/aggregations.
  •  Materialized as TABLE (immutable, deterministic, tiny).
  ──────────────────────────────────────────────────────────────
*/
-}}
{{ config(
     materialized = 'table',
     tags          = ['staging','ethereum'],
     post_hook     = "ANALYZE {{ this }}",       -- keeps stats fresh for query-planner
     contract      = true                        -- schema-enforces downstream contracts
) }}

with src as (

    select *
    from {{ source('ethereum', 'ethereum_rewards_raw') }}

), cleaned as (

    select
        -- == business columns ==================================================
        lower(trim(network))                                  as network,
        lower(trim(protocol))                                 as protocol,
        lower(trim(reward_type))                              as reward_type,
        lower(trim(validator))                                as validator,
        block::bigint                                         as block_id,
        -- reward value normalised to ETH (numeric(38,18))
        (claimed_reward_numeric::numeric
         * power(10::numeric, -claimed_reward_exp::int))      as reward_eth,
        timestamp                                             as reward_ts,
        date_trunc('day', timestamp)                          as reward_date,

        -- == metadata ==========================================================
        processed_at,
        {{ dbt_utils.generate_surrogate_key([
            'validator',
            'reward_type',
            'block::text'      -- “mark” field in the brief
        ]) }}                                                  as sk
    from src
    where lower(type) = 'rewards'        -- defensive filter
)

select * from cleaned
