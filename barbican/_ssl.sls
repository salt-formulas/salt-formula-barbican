{%- from "barbican/map.jinja" import server, system_cacerts_file with context %}

{#

The state reposible for management of CA certificates for the following
tls communications paths used by Barbican:

- messaging (RabbitMQ Server): rabbitmq_ca_barbican_server
- database (MySQL Server): mysql_ca_barbican_server

#}

{%- if server.message_queue.ssl.enabled %}
rabbitmq_ca_barbican_server:
{% if server.message_queue.ssl.cacert is defined %}
  file.managed:
    - name: {{ server.message_queue.ssl.cacert_file }}
    - contents_pillar: barbican:server:message_queue:ssl:cacert
    - mode: 0444
    - makedirs: true
{% else %}
  file.exists:
    - name: {{ server.message_queue.ssl.get('cacert_file', system_cacerts_file) }}
{% endif %}
    - watch_in:
      - service: barbican_server_services
      {% if server.get('async_queues_enable', False) %}
      - service: barbican-worker
      {% endif %}
{% endif %}

{%- if server.database.ssl.enabled %}
mysql_ca_barbican_server:
{% if server.database.ssl.cacert is defined %}
  file.managed:
    - name: {{ server.database.ssl.cacert_file }}
    - contents_pillar: barbican:server:database:ssl:cacert
    - mode: 0444
    - makedirs: true
{% else %}
  file.exists:
    - name: {{ server.database.ssl.get('cacert_file', system_cacerts_file) }}
{% endif %}
    - watch_in:
      - service: barbican_server_services
      {% if server.get('async_queues_enable', False) %}
      - service: barbican-worker
      {% endif %}
    - require_in:
      - cmd: barbican_syncdb
{% endif %}
