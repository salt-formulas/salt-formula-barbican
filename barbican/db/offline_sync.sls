{%- from "barbican/map.jinja" import server with context %}

{%- if server.enabled %}

barbican_syncdb:
  cmd.run:
  - name: barbican-db-manage upgrade
  {%- if grains.get('noservices') or server.get('role', 'primary') == 'secondary' %}
  - onlyif: /bin/false
  {%- endif %}

{%- endif %}
