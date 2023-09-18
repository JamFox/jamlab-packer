#!/bin/bash

# see https://github.com/kwilczynski/packer-templates/blob/899646c9504d5d0e0da2794223a7113d4e13f20c/scripts/common/update.sh
# for a much more complete setup

set -e

if [[ ! -d "/etc/sysctl.d" ]]; then
    mkdir -p "/etc/sysctl.d"
    chown root: "/etc/sysctl.d"
    chmod 755 "/etc/sysctl.d"
fi

# configure VM swappiness
# 1:   disable swap in most circumstances, only avoid killing a process
# 10:  recommended on servers
# 60:  recommended on desktop

cat <<'EOF' > /etc/sysctl.d/10-virtual-memory.conf
vm.swappiness = 1
EOF
