{% macro clear_tests() %}
    {% if execute %}
        {% set database_name, schema_name = elementary.get_package_database_and_schema('elementary') %}
        {% do drop_schema(database_name, schema_name) %}

        {% set tests_schema_name = elementary.get_elementary_tests_schema(database_name, schema_name) %}
        {% if tests_schema_name != schema_name %}
            {% do drop_schema(database_name, tests_schema_name) %}
        {% else %}
            {{ elementary.edr_log("Tests schema is the same as the main elementary schema, nothing to drop.") }}
        {% endif %}
    {% endif %}
    {{ return('') }}
{% endmacro %}

{% macro drop_schema(database_name, schema_name) -%}
    {{ adapter.dispatch('drop_schema', 'elementary')(database_name, schema_name) }}
{%- endmacro %}

{% macro default__drop_schema(database_name, schema_name) %}
    {% set schema_relation = api.Relation.create(database=database_name, schema=schema_name) %}
    {% do dbt.drop_schema(schema_relation) %}
    {% do adapter.commit() %}
    {% do elementary.edr_log("dropped schema {}".format(schema_relation | string)) %}
{% endmacro %}

{% macro dremio__drop_schema(database_name, schema_name) %}
    {{ log(database_name ~ ' ' ~ schema_name, True) }}
    {%- set query -%}
    select TABLE_NAME from information_schema."TABLES"
    where TABLE_SCHEMA = '{{ database_name }}.{{ schema_name }}'
    {%- endset -%}
    {%- set results = run_query(query) -%}
    {%- set results_list = results.columns[0].values() -%}

    {%- for tbl in results_list -%}
        {%- if tbl.startswith('test_') and tbl != 'test_result_rows' -%}
            {%- set drop_table_query -%}
            drop table "{{ database_name }}"."{{ schema_name }}"."{{ tbl }}"
            {%- endset -%}
            {%- do run_query(drop_table_query) -%}
            {% do elementary.edr_log("dropped table {}.{}.{}".format(database_name, schema_name, tbl)) %}
        {%- endif -%}
    {%- endfor -%}

{% endmacro %}
