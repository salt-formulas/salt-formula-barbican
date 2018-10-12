{%- from "barbican/map.jinja" import server, client with context %}

barbican_task_uprade_verify_service:
  test.show_notification:
    - text: "Running barbican.upgrade.verify.service"

