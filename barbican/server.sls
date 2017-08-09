{%- from "barbican/map.jinja" import server with context %}
{%- if server.enabled %}

barbican_server_packages:
  pkg.installed:
  - names: {{ server.pkgs }}

/etc/barbican/barbican.conf:
  file.managed:
  - source: salt://barbican/files/{{ server.version }}/barbican.conf.{{ grains.os_family }}
  - template: jinja
  - require:
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

{%- endif %}
