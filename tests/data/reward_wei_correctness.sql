-- Test passes when result-set is empty
with examples as (

    select 1::numeric        as numeric_col     -- 1 ETH
         , 18::numeric       as exp_col         -- exp = 18  (1 * 10¹⁸ = 1 000 000 000 000 000 000)
         , 1000000000000000000::numeric(38,0) as expected
    
    union all
    select 42, 9, 42000000000                 -- 42 * 10⁹  = 42 000 000 000

)

select *
from   examples
where  {{ reward_wei('numeric_col','exp_col') }} <> expected
