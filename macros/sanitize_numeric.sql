{% macro sanitize_numeric(numeric_col, exp_col) %}
    -- returns a DECIMAL(38,18) ETH amount
    ( {{ numeric_col }} * pow(10::numeric, -{{ exp_col }}) )::numeric(38,18)
{% endmacro %}

