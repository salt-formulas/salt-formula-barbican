
==================================
barbican formula
==================================

Barbican is a REST API designed for the secure storage, provisioning and
management of secrets such as passwords, encryption keys and X.509 Certificates.
It is aimed at being useful for all environments, including large ephemeral
Clouds.

Sample pillars
==============

Single barbican service

.. code-block:: yaml

    barbican:
      server:
        enabled: true
        version: ocata

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
