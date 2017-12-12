{%- from "dogtag/map.jinja" import server with context %}
{%- if server.enabled %}

dogtag_server_packages:
  pkg.installed:
  - names: {{ server.pkgs }}

/etc/dogtag:
  file.directory:
  - makedirs: True
  - user: pkiuser
  - group: pkiuser
  - mode: 600
  - require:
    - pkg: dogtag_server_packages

/etc/dogtag/389-ds_setup.inf:
  file.managed:
  - source: salt://dogtag/files/389-ds_setup.inf
  - template: jinja
  - require:
    - pkg: dogtag_server_packages

setup-ds --silent --file=/etc/dogtag/389-ds_setup.inf:
  cmd.run:
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}
  - require:
    - file: /etc/dogtag/389-ds_setup.inf
  - unless: ldapwhoami -x -p {{ server.ldap_server_port|default(389) }} -h {{ server.ldap_hostname|default('localhost') }} -w {{ server.ldap_dn_password|default('PASSWORD') }} -D '{{ server.ldap_dn|default('cn=Directory Manager') }}'


/etc/dogtag/dogtag.cfg:
  file.managed:
  - source: salt://dogtag/files/dogtag.cfg
  - template: jinja
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

{%- endif %}
{%- endfor %}


{%- if server.get('export_pem_file_path', False) %}
export_dogtag_root_cert_to_pem_file:
  cmd.run:
    - name: openssl pkcs12 -in /root/.dogtag/pki-tomcat/ca_admin_cert.p12 -passin pass:{{ server.default_config_options.get('pki_client_pkcs12_password', 'PASSWORD') }} -out {{ server.export_pem_file_path }} -nodes
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
