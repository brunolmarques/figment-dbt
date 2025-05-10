{% macro load_csv_gz(schema, table) %}
    {% set create_table_query %}
        CREATE SCHEMA IF NOT EXISTS {{ schema }};
        DROP TABLE IF EXISTS {{ schema }}.{{ table }};
        CREATE TABLE {{ schema }}.{{ table }} (
            network text,
            protocol text,
            type text,
            reward_type text,
            validator text,
            block numeric(38,0),
            claimed_reward_currency numeric(38,0),
            claimed_reward_exp numeric(38,0),
            claimed_reward_numeric numeric(38,0),
            claimed_reward_text numeric(38,0),
            processed_at timestamptz,
            timestamp timestamptz
        );
    {% endset %}
    {% do run_query(create_table_query) %}
    {{ log("Created table " ~ schema ~ "." ~ table, info=True) }}
{% endmacro %} 