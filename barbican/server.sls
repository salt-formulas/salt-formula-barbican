{%- from "barbican/map.jinja" import server with context %}
{%- if server.enabled %}

include:
  - barbican._ssl

barbican_server_packages:
  pkg.installed:
  - names: {{ server.pkgs }}

/etc/barbican/barbican.conf:
  file.managed:
  - source: salt://barbican/files/{{ server.version }}/barbican.conf.{{ grains.os_family }}
  - template: jinja
  - require:
    - pkg: barbican_server_packages

barbican_syncdb:
  cmd.run:
  - name: barbican-manage db upgrade
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}
  - require:
    - file: /etc/barbican/barbican.conf
    - pkg: barbican_server_packages

/etc/apache2/conf-enabled/barbican-api.conf:
  file.absent:
  - require:
    - pkg: barbican_server_packages


/etc/apache2/sites-available/barbican-api.conf:
  file.managed:
  - source: salt://barbican/files/{{ server.version }}/barbican-api.apache2.conf.Debian
  - template: jinja
  - require:
    - pkg: barbican_server_packages

barbican_api_config:
  file.symlink:
  - name: /etc/apache2/sites-enabled/barbican-api.conf
  - target: /etc/apache2/sites-available/barbican-api.conf

barbican_apache_restart:
  service.running:
  - enable: true
  - name: apache2
  - watch:
    - file: /etc/barbican/barbican.conf
    - file: /etc/apache2/sites-available/barbican-api.conf

barbican_server_services:
  service.running:
  - names: {{ server.services }}
  - enable: true
  - watch:
    - file: /etc/barbican/barbican.conf

{%- if server.get('async_queues_enable', False) %}
barbican_async_workers_enable:
  service.running:
  - names:
    - barbican-worker
  - enable: true
  - watch:
    - file: /etc/barbican/barbican.conf
{%- else %}
barbican_async_workers_disable:
  service.dead:
  - names:
    - barbican-worker
  - enable: false
{%- endif %}

{%- if 'dogtag' in server.get('plugin', {}) %}
barbican_dogtag_packages:
  pkg.installed:
  - names: {{ server.dogtag_pkgs }}
  - watch_in:
    - service: barbican_server_services

{%- if 'dogtag' in server.get('plugin', {}) %}
{%- if server.dogtag_admin_cert.engine != 'noop' %}
{# For some cases dogtag_admin_cert can be undefined. It is done to rise an exception during the state below. #}
{{ server.plugin.dogtag.get('pem_path', '/etc/barbican/kra_admin_cert.pem') }}:
  file.managed:
  - contents: {{ server.dogtag_admin_cert.key | yaml }}
  - mode: 600
  - user: barbican
  - group: barbican
{%- endif %}
{%- endif %}

{%- endif %}
{%- endif %}
