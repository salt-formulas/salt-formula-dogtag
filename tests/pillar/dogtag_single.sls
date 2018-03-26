dogtag:
  server:
    enabled: True
    export_pem_file_path: /etc/barbican/kra_admin_cert.pem
    ldap_dn_password: password
    ldap_hostname: host
    ldap_admin_password: password
    subsystems:
      CA:
        pki_client_pkcs12_password: password
        enabled: True
      KRA:
        enabled: True
      OCSP:
        enabled: True
      TKS:
        enabled: True
      TPS:
        enabled: True
