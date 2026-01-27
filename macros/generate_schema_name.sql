{% macro generate_schema_name(custom_schema_name, node) %}

  {%- if target.name == 'prod' -%}
      {{ custom_schema_name or target.schema }}

  {%- elif target.name == 'dev' -%}
      {{ target.schema }}_{{ env_var('DBT_USER', 'local') }}

  {%- else -%}
      {{ target.schema }}

  {%- endif -%}

{% endmacro %}
