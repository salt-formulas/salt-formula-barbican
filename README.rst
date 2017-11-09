
================
Barbican formula
================

Barbican is a REST API designed for the secure storage, provisioning and
management of secrets such as passwords, encryption keys and X.509 Certificates.
It is aimed at being useful for all environments, including large ephemeral
Clouds.

Sample pillars
==============

Barbican cluster service

.. code-block:: yaml

    barbican:
      server:
        enabled: true
        version: ocata
        host_href: ''
        is_proxied: true
        plugin:
          simple_crypto:
            kek: "YWJjZGVmZ2hpamtsbW5vcHFyc3R1dnd4eXoxMjM0NTY="
        store:
          software:
            crypto_plugin: simple_crypto
            store_plugin: store_crypto
            global_default: True
        database:
          engine: "mysql+pymysql"
          host: 10.0.106.20
          port: 3306
          name: barbican
          user: barbican
          password: password
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
        cache:
          members:
          - host: 10.10.10.10
            port: 11211
          - host: 10.10.10.11
            port: 11211
          - host: 10.10.10.12
            port: 11211

Running behind loadbalancer

If you are running behind loadbalancer, set the `host_href` to load balancer's
address. You can set `host_href` empty and the api attempts autodetect correct
address from http requests.

.. code-block:: yaml

    barbican:
      server:
        enabled: true
        version: ocata
        host_href: ''


Running behind proxy

If you are running behind proxy, set the `is_proxied` parameter to `true`. This
will allow `host_href` autodetection with help of proxy headers such as
`X-FORWARDED-FOR` and `X-FORWARDED-PROTO`.

.. code-block:: yaml

    barbican:
      server:
        enabled: true
        version: ocata
        host_href: ''
        is_proxied: true

Queuing asynchronous messaging

By default is `async_queues_enable` set `false` to invoke worker tasks
synchronously (i.e. no-queue standalone mode). To enable queuing asynchronous
messaging you need to set it true.

.. code-block:: yaml

    barbican:
      server:
        enabled: true
        version: ocata
        async_queues_enable: true

Keystone notification listener

To enable keystone notification listener, set the `ks_notification_enable`
to true.
`ks_notifications_allow_requeue` enables requeue feature in case of
notification processing error. Enable this only when underlying transport
supports this feature.


.. code-block:: yaml

    barbican:
      server:
        enabled: true
        version: ocata
        ks_notifications_enable: true
        ks_notifications_allow_requeue: true


MySQL server has gone away

MySQL uses a default `wait_timeout` of 8 hours, after which it will drop
idle connections. This can result in 'MySQL Gone Away' exceptions. If you
notice this, you can lower `sql_idle_timeout` to ensure that SQLAlchemy
reconnects before MySQL can drop the connection. If you run MySQL with HAProxy
you need to consider haproxy client/server timeout parameters.

.. code-block:: yaml

    barbican:
      server:
        enabled: true
        version: ocata
        database:
          engine: "mysql+pymysql"
          host: 10.0.106.20
          port: 3306
          name: barbican
          user: barbican
          password: password
          sql_idle_timeout: 180


Configuring TLS communications
------------------------------

**RabbitMQ**

.. code-block:: yaml

 barbican:
   server:
      message_queue:
        port: 5671
        ssl:
          enabled: True
          cacert: cert body if the cacert_file does not exists
          cacert_file: /etc/openstack/rabbitmq-ca.pem



Configuring plugins
-------------------

Dogtag KRA

.. code block:: yaml

    barbican:
      server:
        plugin:
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

KMIP HSM

.. code block:: yaml

    barbican:
      server:
        plugin:
          kmip:
            username: 'admin'
            password: 'password'
            host: localhost
            port: 5696
            keyfile: '/path/to/certs/cert.key'
            certfile: '/path/to/certs/cert.crt'
            ca_certs: '/path/to/certs/LocalCA.crt'


PKCS11 HSM

.. code block:: yaml

    barbican:
      server:
        plugin:
          p11_crypto:
            library_path: '/usr/lib/libCryptoki2_64.so'
            login: 'mypassword'
            mkek_label: 'an_mkek'
            mkek_length: 32
            hmac_label: 'my_hmac_label'



Software Only Crypto

`kek` is key encryption key created from 32 bytes encoded as Base64. You should
not use this in production.

.. code block:: yaml

    barbican:
      server:
        plugin:
          simple_crypto:
            kek: 'YWJjZGVmZ2hpamtsbW5vcHFyc3R1dnd4eXoxMjM0NTY='


Secret stores
-------------

.. code-block:: yaml

    barbican:
      server:
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


Documentation and Bugs
======================

To learn how to install and update salt-formulas, consult the documentation
available online at:

    http://salt-formulas.readthedocs.io/

In the unfortunate event that bugs are discovered, they should be reported to
the appropriate issue tracker. Use GitHub issue tracker for specific salt
formula:

    https://github.com/salt-formulas/salt-formula-barbican/issues

For feature requests, bug reports or blueprints affecting entire ecosystem,
use Launchpad salt-formulas project:

    https://launchpad.net/salt-formulas

Developers wishing to work on the salt-formulas projects should always base
their work on master branch and submit pull request against specific formula.

You should also subscribe to mailing list (salt-formulas@freelists.org):

    https://www.freelists.org/list/salt-formulas

Any questions or feedback is always welcome so feel free to join our IRC
channel:

    #salt-formulas @ irc.freenode.net

Read more
=========

* https://docs.openstack.org/barbican/latest/
