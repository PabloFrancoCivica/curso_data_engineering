{% macro filtro_no_borrados(alias='') %}
    {% if alias %}
        {{ alias }}._FIVETRAN_DELETED IS NULL
    {% else %}
        _FIVETRAN_DELETED IS NULL
    {% endif %}
{% endmacro %}
