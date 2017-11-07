{%- if pillar.dogtag is defined %}
include:
{%- if pillar.dogtag.server is defined %}
- dogtag.server
{%- endif %}
{%- if pillar.dogtag.client is defined %}
- dogtag.client
{%- endif %}
{%- endif %}
