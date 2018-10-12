{%- from "barbican/map.jinja" import server with context %}

barbican_post:
  test.show_notification:
    - name: "dump_message_post-upgrade"
    - text: "Running barbican.upgrade.post"

keystone_os_client_config_absent:
  file.absent:
    - name: /etc/openstack/clouds.yml
