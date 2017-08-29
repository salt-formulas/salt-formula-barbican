{%- from "barbican/map.jinja" import client with context %}
{%- if client.enabled %}

barbican_client_packages:
  pkg.installed:
  - names: {{ client.pkgs }}

{%- endif %}
