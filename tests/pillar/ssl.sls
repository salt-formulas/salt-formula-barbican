include:
  - .control_single

barbican:
  server:
    message_queue:
      port: 5671
      ssl:
        # Case #1: specify cacert file and ca cert body explicitly
        enabled: True
        cacert_file: /etc/barbican/ssl/rabbitmq_cacert.pem
        cacert: |
            -----BEGIN CERTIFICATE-----
            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
            /86PB1o=
            -----END CERTIFICATE-----
