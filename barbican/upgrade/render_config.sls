{%- from "barbican/map.jinja" import server, client with context %}

barbican_render_config:
  test.show_notification:
    - name: "dump_message_render_config_barbican"
    - text: "Running barbican.upgrade.render_config"

/etc/barbican/barbican.conf:
  file.managed:
  - source: salt://barbican/files/{{ server.version }}/barbican.conf.{{ grains.os_family }}
  - template: jinja
  - mode: 0640
  - group: barbican
