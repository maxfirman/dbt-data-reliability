{%- macro edr_stddev(field) -%}
    {{ return(adapter.dispatch('edr_stddev', 'elementary')(field)) }}
{%- endmacro -%}

{%- macro default__edr_stddev(field) -%}
    stddev({{ field }})
{%- endmacro -%}

{%- macro dremio__edr_stddev(field) -%}
    stddev_pop({{ field }})
{%- endmacro -%}
