{{ config(
    pre_hook = "{{ log_step('Start staging ethereum_rewards') }}",
    post_hook = "{{ log_step('Finished staging ethereum_rewards') }}",
    materialized='table',
    tags=['staging','ethereum', 'staging_generic_tests']
) }}

with src as (

    select *
    from {{ source('ethereum', 'ethereum_rewards_raw') }}

), renamed as (

    select
        lower(trim(network))              as network,
        lower(trim(protocol))             as protocol,
        lower(trim(type))                 as record_type,       -- ‘rewards’ expected
        lower(trim(reward_type))          as reward_type,
        lower(trim(validator))            as validator,         -- “address” in spec
        block::numeric(38,0)              as block_number,
        {{ reward_wei('claimed_reward_numeric', 'claimed_reward_exp') }}
                                            as reward_wei,
        claimed_reward_numeric            as raw_numeric,
        processed_at,
        timestamp                         as block_ts
    from src

), dedup as (

    select *
    from (
        select *,
               row_number() over (
                   partition by validator, reward_type, block_number
                   order by processed_at desc  -- keep most recent ingest
               ) as rn
        from renamed
    ) where rn = 1

), filtered as (

    -- remove unsupported reward_type values early
    select f.*
    from dedup f
    left join {{ ref('reward_type_reference') }} r
           on f.reward_type = r.reward_type
    where r.reward_type is not null

)

select
    *,
    block_ts::date as reward_date          -- for daily rollups later
from filtered