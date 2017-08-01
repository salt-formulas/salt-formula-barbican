{%- if pillar.barbican is defined %}
include:
{%- if pillar.barbican.server is defined %}
- barbican.server
{%- endif %}
{%- endif %}
