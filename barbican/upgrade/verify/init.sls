barbican_upgrade_verify:
  test.show_notification:
    - name: "dump_message_upgrade_barbican_verify"
    - text: "Running barbican.upgrade.verify"

include:
 - barbican.upgrade.verify._api
 - barbican.upgrade.verify._service
