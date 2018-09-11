{%- from "barbican/map.jinja" import server with context %}

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
    - name: {{ server.message_queue.ssl.get('cacert_file', server.cacert_file) }}
{% endif %}
    - watch_in:
      - service: barbican_server_services
      {% if server.get('async_queues_enable', False) %}
      - service: barbican-worker
      {% endif %}
{% endif %}
