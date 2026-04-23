{% macro generate_event_sk(columns) -%}
  {{ dbt_utils.generate_surrogate_key(columns) }}
{%- endmacro %}
