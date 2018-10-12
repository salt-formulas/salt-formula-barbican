{%- from "barbican/map.jinja" import server, client with context %}

barbican_upgrade_pre:
  test.show_notification:
    - name: "dump_message_upgrade_barbican_pre"
    - text: "Running barbican.upgrade.upgrade.pre"
