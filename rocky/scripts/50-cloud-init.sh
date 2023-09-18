#!/bin/bash

set -e

dnf install -y cloud-init cloud-utils-growpart gdisk

if [[ ! -d "/etc/cloud/cloud.cfg.d" ]]; then
    mkdir -p "/etc/cloud/cloud.cfg.d"
    chown root: "/etc/cloud/cloud.cfg.d"
    chmod 755 "/etc/cloud/cloud.cfg.d"
fi
