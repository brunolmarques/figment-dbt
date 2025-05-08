{% macro strip_0x(address) %}
    regexp_replace({{ address }}, '^0x', '')
{% endmacro %}