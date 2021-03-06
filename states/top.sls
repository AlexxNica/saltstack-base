
base:

  'G@saltstack-base:role:master':
    - local
    - selinux
    - iptables
    - network
    - kernel
    - yumrepo
    - packages
    - ssd
{% if grains['os_family'] == 'RedHat' and grains['osmajorrelease'] == '7' %}
    - cpupower
{% elif grains['os_family'] == 'RedHat' and grains['osmajorrelease'] == '6' %}
    - cpuspeed
{% endif %}
    - ntp.server
    - users
    - irqbalance

  'G@saltstack-base:role:minion':
    - local
    - selinux
# NOTE: iptables is required for juno-saltstack
#    - iptables
    - network
    - kernel
    - yumrepo
    - packages
    - ssd
{% if grains['os_family'] == 'RedHat' and grains['osmajorrelease'] == '7' %}
    - cpupower
{% elif grains['os_family'] == 'RedHat' and grains['osmajorrelease'] == '6' %}
    - cpuspeed
{% endif %}
    - ntp.client
    - users
    - irqbalance
