#!/bin/bash

set -e

apt-get -y install cloud-init

if [[ ! -d "/etc/cloud/cloud.cfg.d" ]]; then
    mkdir -p "/etc/cloud/cloud.cfg.d"
    chown root: "/etc/cloud/cloud.cfg.d"
    chmod 755 "/etc/cloud/cloud.cfg.d"
fi
