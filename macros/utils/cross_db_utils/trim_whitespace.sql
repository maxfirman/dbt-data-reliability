{%- macro edr_trim_whitespace(field) -%}
    {{ return(adapter.dispatch('edr_trim_whitespace', 'elementary')(field)) }}
{%- endmacro %}

{%- macro default__edr_trim_whitespace(field) -%}
    trim({{ field }}, ' ')
{%- endmacro %}

{%- macro dremio__edr_trim_whitespace(field) -%}
    trim({{ field }})
{%- endmacro %}
