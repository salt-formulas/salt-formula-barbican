{%- if pillar.barbican is defined %}
include:
{%- if pillar.barbican.server is defined %}
- barbican.server
{%- endif %}
{%- if pillar.barbican.client is defined %}
- barbican.client
{%- endif %}
{%- endif %}
