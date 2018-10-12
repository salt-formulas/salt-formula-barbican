{%- from "barbican/map.jinja" import server, client with context %}

barbican_pre:
  test.show_notification:
    - name: "dump_message_pre-upgrade_barbican"
    - text: "Running barbican.upgrade.pre"

python-os-client-config_package:
  pkg.latest:
  - name: python-os-client-config

{%- set os_content = salt['mine.get']('I@keystone:client:os_client_config:enabled:true', 'keystone_os_client_config', 'compound').values()[0] %}
keystone_os_client_config:
  file.managed:
    - name: /etc/openstack/clouds.yml
    - contents: |
        {{ os_content |yaml(False)|indent(8) }}
    - user: 'root'
    - group: 'root'
    - makedirs: True
    - unless: test -f /etc/openstack/clouds.yml
    - require:
      - pkg: python-os-client-config_package
