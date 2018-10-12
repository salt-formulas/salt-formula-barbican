{%- from "barbican/map.jinja" import server, client with context %}

barbican_upgrade:
  test.show_notification:
    - name: "dump_message_upgrade_barbican"
    - text: "Running barbican.upgrade.upgrade"

include:
 - barbican.upgrade.service_stopped
 - barbican.upgrade.pkgs_latest
 - barbican.upgrade.render_config
 - barbican.db.offline_sync
 - barbican.upgrade.service_running
