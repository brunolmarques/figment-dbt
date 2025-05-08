{% macro log_step(msg) %}
    {{ log("📋 " ~ msg, info=True) }}
{% endmacro %}