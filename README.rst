
=====================
Dogtag salt formula
=====================

Sample pillars
==============

.. code-block:: yaml
  dogtag:
    server:
      ldap_hostname: hostname.somedomain.com
      export_pem_file_path: /etc/barbican/kra_admin_cert.pem

Define paramters for all Dogtag subsystems:

.. code-block:: yaml
  dogtag:
    server:
      ldap_hostname: hostname.somedomain.com
      ldap_dn_password: ds_password
      export_pem_file_path: /etc/barbican/kra_admin_cert.pem
      default_config_options:
        pki_ds_hostname: hostname.somedomain.com
        pki_admin_password: workshop
        pki_ds_password: ds_password


Define paramters for specific DogTag subsystem:

.. code-block:: yaml
  dogtag:
    server:
      export_pem_file_path: /etc/barbican/kra_admin_cert.pem
      subsystems:
        KRA:
          pki_admin_name: krakraadmin


Disable specific DogTag subsystem:

.. code-block:: yaml
  dogtag:
    server:
      export_pem_file_path: /etc/barbican/kra_admin_cert.pem
      subsystems:
        TPS:
          enabled: False


Development and testing
=======================

Development and test workflow with `Test Kitchen <http://kitchen.ci>`_ and
`kitchen-salt <https://github.com/simonmcc/kitchen-salt>`_ provisioner plugin.

Test Kitchen is a test harness tool to execute your configured code on one or more platforms in isolation.
There is a ``.kitchen.yml`` in main directory that defines *platforms* to be tested and *suites* to execute on them.

Kitchen CI can spin instances locally or remote, based on used *driver*.
For local development ``.kitchen.yml`` defines a `vagrant <https://github.com/test-kitchen/kitchen-vagrant>`_ or
`docker  <https://github.com/test-kitchen/kitchen-docker>`_ driver.

To use backend drivers or implement your CI follow the section `INTEGRATION.rst#Continuous Integration`__.

The `Busser <https://github.com/test-kitchen/busser>`_ *Verifier* is used to setup and run tests
implementated in `<repo>/test/integration`. It installs the particular driver to tested instance
(`Serverspec <https://github.com/neillturner/kitchen-verifier-serverspec>`_,
`InSpec <https://github.com/chef/kitchen-inspec>`_, Shell, Bats, ...) prior the verification is executed.

Usage:

.. code-block:: shell

  # list instances and status
  kitchen list

  # manually execute integration tests
  kitchen [test || [create|converge|verify|exec|login|destroy|...]] [instance] -t tests/integration

  # use with provided Makefile (ie: within CI pipeline)
  make kitchen


