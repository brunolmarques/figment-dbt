{% macro incremental_merge(target, unique_keys, updated_at) %}
    {#-
      target       → relation passed as {{ this }}
      unique_keys  → list, e.g. ['validator','date']
      updated_at   → col holding the load timestamp
    -#}
    {% set uk  = unique_keys | join(', ') %}
    merge into {{ target }} as t
    using staging as s
       on {% for col in unique_keys %}
             t.{{ col }} = s.{{ col }}{% if not loop.last %} and{% endif %}
          {% endfor %}
    when matched and s.{{ updated_at }} > t.{{ updated_at }}
        then update set *
    when not matched
        then insert *
    ;
{% endmacro %}