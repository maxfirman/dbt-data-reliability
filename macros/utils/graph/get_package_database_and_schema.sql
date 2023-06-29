{% macro get_package_database_and_schema(package_name='elementary') %}
    {{ return(adapter.dispatch('get_package_database_and_schema', 'elementary')(package_name)) }}
{% endmacro %}

{% macro default__get_package_database_and_schema(package_name) %}
    {% if execute %}
        {% set node_in_package = graph.nodes.values()
                                 | selectattr("resource_type", "==", "model")
                                 | selectattr("package_name", "==", package_name) | first %}
        {% if node_in_package %}
            {{ return([node_in_package.database, node_in_package.schema]) }}
        {% endif %}
    {% endif %}
    {{ return([none, none]) }}
{% endmacro %}

{% macro dremio__get_package_database_and_schema(package_name) %}
    {{ return([target.object_storage_source, target.object_storage_path]) }}
{% endmacro %}

