{% macro get_columns_from_information_schema(schema_tuple) %}
    {%- set database_name, schema_name = schema_tuple %}
    {{ return(adapter.dispatch('get_columns_from_information_schema', 'elementary')(database_name, schema_name)) }}
{% endmacro %}

{# Snowflake, Bigquery#}
{% macro default__get_columns_from_information_schema(database_name, schema_name) %}
    {% set schema_relation = api.Relation.create(database=database_name, schema=schema_name).without_identifier() %}

    select
        upper(table_catalog || '.' || table_schema || '.' || table_name) as full_table_name,
        upper(table_catalog) as database_name,
        upper(table_schema) as schema_name,
        upper(table_name) as table_name,
        upper(column_name) as column_name,
        data_type
    from {{ schema_relation.information_schema('COLUMNS') }}
    where upper(table_schema) = upper('{{ schema_name }}')

{% endmacro %}

{% macro redshift__get_columns_from_information_schema(database_name, schema_name) %}
    select
        upper(table_catalog || '.' || table_schema || '.' || table_name) as full_table_name,
        upper(table_catalog) as database_name,
        upper(table_schema) as schema_name,
        upper(table_name) as table_name,
        upper(column_name) as column_name,
        data_type
    from pg_catalog.svv_columns
    where upper(table_schema) = upper('{{ schema_name }}')

{% endmacro %}

{% macro postgres__get_columns_from_information_schema(database_name, schema_name) %}
    select
        upper(table_catalog || '.' || table_schema || '.' || table_name) as full_table_name,
        upper(table_catalog) as database_name,
        upper(table_schema) as schema_name,
        upper(table_name) as table_name,
        upper(column_name) as column_name,
        data_type
    from information_schema.columns
    where upper(table_schema) = upper('{{ schema_name }}')

{% endmacro %}

{% macro spark__get_columns_from_information_schema(database_name, schema_name) %}
    {{ elementary.get_empty_columns_from_information_schema_table() }}
{% endmacro %}

{% macro get_empty_columns_from_information_schema_table() %}
    {{ elementary.empty_table([('full_table_name', 'string'), ('database_name', 'string'), ('schema_name', 'string'), ('table_name', 'string'), ('column_name', 'string'), ('data_type', 'string')]) }}
{% endmacro %}

{% macro dremio__get_columns_from_information_schema(database_name, schema_name) %}

select
    upper( table_schema || '.' || table_name) as full_table_name,
    upper(flatten(sublist(regexp_split(table_schema, '\.', 'FIRST', -1), 0, 1))) as database_name,
    upper(flatten(sublist(regexp_split(table_schema, '\.', 'FIRST', -1), -1, 1))) as schema_name,
    upper(table_name) as table_name,
    upper(column_name) as column_name,
    data_type
from INFORMATION_SCHEMA."COLUMNS"
where upper(table_schema) = upper('{{ database_name }}.{{ schema_name }}')

{% endmacro %}

