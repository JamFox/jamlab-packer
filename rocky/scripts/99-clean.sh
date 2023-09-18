#!/bin/bash

set -eux

# Avoid ~200 meg firmware package we don't need
# this cannot be done in the KS file so we do it here
dnf -y remove linux-firmware
dnf -y autoremove
dnf -y clean all  --enablerepo=\*;

cloud-init clean
rm -rf /var/cache/dnf/*

truncate -s 0 /etc/machine-id
ln -s /etc/machine-id

shred -u /etc/ssh/*_key /etc/ssh/*_key.pub
unset HISTFILE; rm -rf /root/.*history; rm -rf ~/.*history
rm -f /root/*ks.cfg

rm -rf /tmp/*
rm -rf /var/tmp/*
rm -f /var/run/utmp

find /var/log -type f -exec truncate --size=0 {} \;
rm -f /root/anaconda-ks.cfg /root/original-ks.cfg
rm -f /var/lib/systemd/random-seed
rm -f /etc/resolv.conf

dd if=/dev/zero of=/EMPTY bs=1M || true
rm -f /EMPTY

sync

rm -f /root/.wget-hsts
export HISTSIZE=0

# @TODO more cleanup probably
# https://github.com/DanHam/packer-virt-sysprep
# https://github.com/DanHam/packer-virt-sysprep-example


# ref https://github.com/runter-vom-mattenwagen/proxmox-packer/blob/main/rocky/setup.sh
