{%- from "barbican/map.jinja" import server, client with context %}

barbican_task_service_stopped:
  test.show_notification:
    - name: "dump_message_service_stopped_barbican"
    - text: "Running barbican.upgrade.service_stopped"

{%- set bservices = [] %}
{%- do bservices.extend(server.services) %}

{%- if server.get('enabled') %}
  {%- do bservices.append('apache2') %}
{%- endif %}

{%- if bservices|unique|length > 0 %}
  {%- for service in bservices|unique %}
barbican_service_stopped_{{ service }}:
  service.dead:
  - enable: false
  - name: {{ service }}
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}
  {%- endfor %}
{%- endif %}

