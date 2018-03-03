barbican:
  server:
    enabled: true
    version: ocata
    host_href: ''
    is_proxied: true
    dogtag_admin_cert:
      engine: manual
      key: 'some dogtag key'
    plugin:
      simple_crypto:
        kek: "YWJjZGVmZ2hpamtsbW5vcHFyc3R1dnd4eXoxMjM0NTY="
      p11_crypto:
        library_path: '/usr/lib/libCryptoki2_64.so'
        login: 'mypassword'
        mkek_label: 'an_mkek'
        mkek_length: 32
        hmac_label: 'my_hmac_label'
      kmip:
        username: 'admin'
        password: 'password'
        host: localhost
        port: 5696
        keyfile: '/path/to/certs/cert.key'
        certfile: '/path/to/certs/cert.crt'
        ca_certs: '/path/to/certs/LocalCA.crt'
      dogtag:
        pem_path: '/etc/barbican/kra_admin_cert.pem'
        dogtag_host: localhost
        dogtag_port: 8443
        nss_db_path: '/etc/barbican/alias'
        nss_db_path_ca: '/etc/barbican/alias-ca'
        nss_password: 'password123'
        simple_cmc_profile: 'caOtherCert'
        ca_expiration_time: 1
        plugin_working_dir: '/etc/barbican/dogtag'
    store:
      software:
        crypto_plugin: simple_crypto
        store_plugin: store_crypto
        global_default: True
      kmip:
        store_plugin: kmip_plugin
      dogtag:
        store_plugin: dogtag_crypto
      pkcs11:
        store_plugin: store_crypto
        crypto_plugin: p11_crypto
    database:
      engine: "mysql+pymysql"
      host: 10.0.106.20
      port: 3306
      name: barbican
      user: barbican
      password: password
      ssl:
        enabled: True
    bind:
      address: 10.0.106.20
      port: 9311
      admin_port: 9312
    identity:
      engine: keystone
      host: 10.0.106.20
      port: 35357
      domain: default
      tenant: service
      user: barbican
      password: password
    message_queue:
      engine: rabbitmq
      user: openstack
      password: password
      virtual_host: '/openstack'
      members:
      - host: 10.10.10.10
        port: 5672
      - host: 10.10.10.11
        port: 5672
      - host: 10.10.10.12
        port: 5672
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
    cache:
      members:
      - host: 10.10.10.10
        port: 11211
      - host: 10.10.10.11
        port: 11211
      - host: 10.10.10.12
        port: 11211
apache:
  server:
    enabled: true
    default_mpm: event
    mpm:
      prefork:
        enabled: true
        servers:
          start: 5
          spare:
            min: 2
            max: 10
        max_requests: 0
        max_clients: 20
        limit: 20
    site:
      barbican:
        enabled: false
        available: true
        type: wsgi
        name: barbican
        wsgi:
          daemon_process: barbican-api
          processes: 3
          threads: 10
          user: barbican
          group: barbican
          display_name: '%{GROUP}'
          script_alias: '/ /usr/bin/barbican-wsgi-api'
          application_group: '%{GLOBAL}'
          authorization: 'On'
        host:
          address: 127.0.0.1
          name: 127.0.0.1
          port: 9311
      barbican_admin:
        enabled: false
        available: true
        type: wsgi
        name: barbican_admin
        wsgi:
          daemon_process: barbican-api-admin
          processes: 3
          threads: 10
          user: barbican
          group: barbican
          display_name: '%{GROUP}'
          script_alias: '/ /usr/bin/barbican-wsgi-api'
          application_group: '%{GLOBAL}'
          authorization: 'On'
        host:
          address: 127.0.0.1
          name: 127.0.0.1
          port: 9312
