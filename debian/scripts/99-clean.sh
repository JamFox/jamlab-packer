#!/bin/bash

set -eux

apt-get -y autoremove --purge
apt-get -y clean
cloud-init clean

rm -rf /tmp/*
rm -rf /var/tmp/*

find /var/log/ -name *.log -exec rm -f {} \;
rm -f /root/.bash_history
# Replace DNS config from DHCP with something generic.
# You will need to manage this file somehow on its children.
# cloud-init network config adds nameservers
# using `dns-nameservers 8.0.0.8` in /etc/network/interfaces.d,
# which relies on resolvconf or NetworkManager (which is why it
# works on RHEL family by default).
cat << EOF > /etc/resolv.conf
nameserver 1.1.1.1
nameserver 8.8.8.8
EOF

dd if=/dev/zero of=/EMPTY bs=1M || true
rm -f /EMPTY

sync

# @TODO more cleanup probably
# https://github.com/DanHam/packer-virt-sysprep
# https://github.com/DanHam/packer-virt-sysprep-example
