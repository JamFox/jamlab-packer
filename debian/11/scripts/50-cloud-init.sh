#!/bin/bash

set -e

if [[ "$BACKPORTS" = "yes" ]]; then
    apt-get -y -t bullseye-backports install cloud-init net-tools
else
    apt-get -y install cloud-init
fi

if [[ ! -d "/etc/cloud/cloud.cfg.d" ]]; then
    mkdir -p "/etc/cloud/cloud.cfg.d"
    chown root: "/etc/cloud/cloud.cfg.d"
    chmod 755 "/etc/cloud/cloud.cfg.d"
fi
