{%- from "barbican/map.jinja" import server with context %}
{%- if server.enabled %}

include:
  - apache
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

barbican_sync_secret_stores:
  cmd.run:
  - name: barbican-manage db sync_secret_stores
  {%- if grains.get('noservices') or server.version in ['ocata', 'pike'] %}
  - onlyif: /bin/false
  {%- endif %}
  - require:
    - file: /etc/barbican/barbican.conf
    - pkg: barbican_server_packages
    - cmd: barbican_syncdb

{%- if server.logging.log_appender %}

{%- if server.logging.log_handlers.get('fluentd', {}).get('enabled', False) %}
barbican_fluentd_logger_package:
  pkg.installed:
    - name: python-fluent-logger
{%- endif %}

/etc/barbican/logging.conf:
  file.managed:
    - user: barbican
    - group: barbican
    - source: salt://oslo_templates/files/logging/_logging.conf
    - template: jinja
    - defaults:
        service_name: barbican
        _data: {{ server.logging }}
    - require:
      - pkg: barbican_server_packages
      - file: /etc/barbican/barbican.conf
{%- if server.logging.log_handlers.get('fluentd', {}).get('enabled', False) %}
      - pkg: barbican_fluentd_logger_package
{%- endif %}
    - require_in:
      - cmd: barbican_syncdb
    - watch_in:
      - service: barbican_server_services

/var/log/barbican/barbican.log:
  file.managed:
    - user: barbican
    - group: barbican
    - watch_in:
      - service: barbican_server_services

{%- endif %}

{#- Creation of sites using templates is deprecated, sites should be generated by apache pillar, and enabled by barbican formula #}
{%- if pillar.get('apache', {}).get('server', {}).get('site', {}).barbican is not defined %}

barbican_cleanup_configs:
  file.absent:
  - name: /etc/apache2/conf-enabled/barbican-api.conf
  - require:
    - pkg: barbican_server_packages

barbican_apache_conf_file:
  file.managed:
  - name: /etc/apache2/sites-available/barbican-api.conf
  - source: salt://barbican/files/{{ server.version }}/barbican-api.apache2.conf.Debian
  - template: jinja
  - require:
    - pkg: barbican_server_packages
    - barbican_cleanup_configs

apache_enable_barbican_wsgi:
  apache_site.enabled:
    - name: barbican-api
    - require:
      - barbican_apache_conf_file

{%- else %}

barbican_cleanup_configs:
  file.absent:
    - names:
      - '/etc/apache2/sites-available/barbican-api.conf'
      - '/etc/apache2/sites-enabled/barbican-api.conf'
      - '/etc/apache2/conf-enabled/barbican-api.conf'

barbican_apache_conf_file:
  file.exists:
  - names:
    - /etc/apache2/sites-available/wsgi_barbican.conf
    - /etc/apache2/sites-available/wsgi_barbican_admin.conf
  - require:
    - pkg: barbican_server_packages
    - barbican_cleanup_configs

apache_enable_barbican_wsgi:
  apache_site.enabled:
    - names:
      - wsgi_barbican
      - wsgi_barbican_admin
    - require:
      - barbican_apache_conf_file

{%- endif %}

barbican_apache_restart:
  service.running:
  - enable: true
  - name: apache2
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}
  - watch:
    - file: /etc/barbican/barbican.conf
    - barbican_apache_conf_file

barbican_server_services:
  service.running:
  - names: {{ server.services }}
  - enable: true
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}
  - watch:
    - file: /etc/barbican/barbican.conf

{%- if server.get('async_queues_enable', False) %}
barbican_async_workers_enable:
  service.running:
  - names:
    - barbican-worker
  - enable: true
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}
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
