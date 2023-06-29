{% macro assert_value(actual, expected) %}
    {% if actual == expected %}
        {% do elementary.edr_log(context ~ " SUCCESS: " ~ actual  ~ " == " ~ expected) %}
        {{ return(0) }}
    {% else %}
        {% do elementary.edr_log(context ~ " FAILED: " ~ actual ~ " != " ~ expected) %}
        {{ return(1) }}
    {% endif %}
{% endmacro %}
