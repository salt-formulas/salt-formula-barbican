{%- from "barbican/map.jinja" import server, client with context %}

barbican_upgrade_verify_api:
  test.show_notification:
    - name: "dump_message_verify_api_barbican"
    - text: "Running barbican.upgrade.verify.api"

{%- if server.enabled %}
  {%- set secret_name = 'api_verify_secret_test' %}
  {%- set secret_payload = salt['hashutil.base64_b64encode']('My_SaltTest_Payload') %}

barbicanv1_secret_list:
  module.run:
    - name: barbicanv1.secret_list
    - kwargs:
        cloud_name: admin_identity

barbican_secret_present:
  barbicanv1.secret_present:
  - cloud_name: admin_identity
  - name: SaltTestSecret
  - algorithm: RSA
  - secret_type: certificate
  - payload: {{ secret_payload }}
  - payload_content_type: application/octet-stream
  - payload_content_encoding: base64

barbican_secret_absent:
  barbicanv1.secret_absent:
  - cloud_name: admin_identity
  - name: SaltTestSecret
  - require:
    - barbican_secret_present

{%- endif %}
