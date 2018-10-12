{%- from "barbican/map.jinja" import server, client with context %}

barbican_upgrade_post:
  test.show_notification:
    - name: "dump_message_upgrade_barbican_post"
    - text: "Running barbican.upgrade.upgrade.post"
