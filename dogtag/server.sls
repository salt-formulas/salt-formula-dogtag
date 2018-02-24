{%- from "dogtag/map.jinja" import server with context %}
{%- if server.get('enabled', False) %}

dogtag_server_packages:
  pkg.installed:
  - names: {{ server.pkgs }}

/etc/dogtag:
  file.directory:
  - makedirs: True
  - user: pkiuser
  - group: pkiuser
  - mode: 750
  - require:
    - pkg: dogtag_server_packages

/etc/dogtag/389-ds_setup.inf:
  file.managed:
  - source: salt://dogtag/files/389-ds_setup.inf
  - template: jinja
  - user: pkiuser
  - group: pkiuser
  - mode: 640
  - require:
    - pkg: dogtag_server_packages

setup-ds --silent --file=/etc/dogtag/389-ds_setup.inf:
  cmd.run:
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}
  - require:
    - file: /etc/dogtag/389-ds_setup.inf
  - unless: ldapwhoami -x -p {{ server.ldap_server_port|default(389) }} -h {{ server.ldap_hostname|default('localhost') }} -w {{ server.ldap_dn_password }} -D '{{ server.ldap_dn|default('cn=Directory Manager') }}'

{%- if server.get('role', 'master') == 'slave' %}
/etc/dogtag/ca-certs.p12:
  file.decode:
    - name: /etc/dogtag/ca-certs.p12
    - encoding_type: base64
    - encoded_data: "{{ server.dogtag_certs }}"

/etc/dogtag/ca-certs.p12_rights:
  file.managed:
    - name: /etc/dogtag/ca-certs.p12
    - user: pkiuser
    - group: pkiuser
    - mode: 640
{%- endif %}

/etc/dogtag/dogtag.cfg:
  file.managed:
  - source: salt://dogtag/files/dogtag.cfg
  - template: jinja
  - user: pkiuser
  - group: pkiuser
  - mode: 640
  - require:
     - pkg: dogtag_server_packages

{# Need to use exact order of subsystems #}
{%- for key_name in ('CA', 'KRA', 'OCSP', 'TKS', 'TPS') %}
{%- set key=server.subsystems.get(key_name, False) %}
{%- if key and key.get('enabled', False) %}

{%- if key and key.get('pkgs', False) %}
dogtag_{{ key_name }}_subsystem_packages:
  pkg.installed:
  - names: {{ key.pkgs }}
{%- endif %}

pkispawn -f /etc/dogtag/dogtag.cfg -s {{ key_name }}:
  cmd.run:
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}
  - unless: pki-server subsystem-show {{ key_name|lower }}
  - require:
    - file: /etc/dogtag/dogtag.cfg

{%- endif %}
{%- endfor %}

{%- if server.get('role', 'master') == 'master' %}
export_dogtag_certs:
  cmd.run:
    - name: grep "internal=" /var/lib/pki/pki-tomcat/conf/password.conf | awk -F= '{print $2}' > /etc/dogtag/internal.txt && echo {{ server.default_config_options.get('pki_clone_pkcs12_password') }} > /etc/dogtag/pass.txt && PKCS12Export -debug  -d /var/lib/pki/pki-tomcat/alias -p /etc/dogtag/internal.txt -o /etc/dogtag/ca-certs.p12 -w /etc/dogtag/pass.txt && rm -f /etc/dogtag/internal.txt /etc/dogtag/pass.txt && cat /etc/dogtag/ca-certs.p12 | base64 > /etc/dogtag/ca-certs.p12.base64
    {%- if grains.get('noservices') %}
    - onlyif: /bin/false
    {%- endif %}

mine_send_dogtag_certs:
  module.run:
    - name: mine.send
    - func: dogtag_certs
    - kwargs:
        mine_function: cmd.run
    - args:
      - 'cat /etc/dogtag/ca-certs.p12.base64'
    - onchanges:
      - cmd: export_dogtag_certs

{%- if server.get('export_pem_file_path', False) %}
export_dogtag_root_cert_to_pem_file:
  cmd.run:
    - name: openssl pkcs12 -in /root/.dogtag/pki-tomcat/ca_admin_cert.p12 -passin pass:{{ server.default_config_options.get('pki_client_pkcs12_password') }} -out {{ server.export_pem_file_path }} -nodes
    - umask: 077
    {%- if grains.get('noservices') %}
    - onlyif: /bin/false
    {%- endif %}
    - unless: 'test -f {{ server.export_pem_file_path }}'

mine_send_{{ server.export_pem_file_path }}:
  module.run:
    - name: mine.send
    - func: dogtag_admin_cert
    - kwargs:
        mine_function: cmd.run
    - args:
      - 'cat {{ server.export_pem_file_path }}'
    - onchanges:
      - cmd: export_dogtag_root_cert_to_pem_file
{%- endif %}
{%- endif %}


{%- endif %}
