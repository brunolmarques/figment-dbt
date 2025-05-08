{% macro reward_wei(numeric_col, exp_col) %}
    ( {{ numeric_col }} * power(10, {{ exp_col }}) )::numeric(38,0)
{% endmacro %}