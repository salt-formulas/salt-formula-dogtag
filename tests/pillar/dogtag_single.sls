dogtag:
  server:
    enabled: True
    export_pem_file_path: /etc/barbican/kra_admin_cert.pem
    ldap_dn_password: password
    ldap_hostname: host
    subsystems:
      CA:
        enabled: True
      KRA:
        enabled: True
      OCSP:
        enabled: True
      TKS:
        enabled: True
      TPS:
        enabled: True
