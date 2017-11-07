
==================================
dogtag
==================================

Service dogtag description

Sample pillars
==============

Single dogtag service

.. code-block:: yaml
  dogtag:
    server:
      ldap_hostname: hostname.somedomain.com
      export_pem_file_path: /etc/barbican/kra_admin_cert.pem

Define paramters for all Dogtag subsystems
=============
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


Define paramters for specific DogTag subsystem
=============
.. code-block:: yaml
  dogtag:
    server:
      export_pem_file_path: /etc/barbican/kra_admin_cert.pem
      subsystems:
        KRA:
          pki_admin_name: krakraadmin


Disable specific DogTag subsystem
=============
.. code-block:: yaml
  dogtag:
    server:
      export_pem_file_path: /etc/barbican/kra_admin_cert.pem
      subsystems:
        TPS:
          enabled: False

