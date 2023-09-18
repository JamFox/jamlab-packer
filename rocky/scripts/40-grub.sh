#!/bin/bash

# This still has to be improved, skipping the menu does not work currently eg.

set -e
export PATH='/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'


# KERNEL_OPTIONS=(
#     'systemd.journald.forward_to_console=1'
#     'console=ttyS0,38400'
#     'console=tty1'
# )

grep "GRUB_TERMINAL=" /etc/default/grub || echo 'GRUB_TERMINAL="serial console"' >> /etc/default/grub
grep "GRUB_SERIAL_COMMAND=" /etc/default/grub || echo 'GRUB_SERIAL_COMMAND=""' >> /etc/default/grub
grep "GRUB_DEFAULT=" /etc/default/grub || echo 'GRUB_DEFAULT=0' >> /etc/default/grub
grep "GRUB_TIMEOUT_STYLE=" /etc/default/grub || echo 'GRUB_TIMEOUT_STYLE=hidden' >> /etc/default/grub
grep "GRUB_TIMEOUT=" /etc/default/grub || echo 'GRUB_TIMEOUT=0' >> /etc/default/grub
grep "GRUB_DISABLE_RECOVERY=" /etc/default/grub || echo 'GRUB_DISABLE_RECOVERY="true"' >> /etc/default/grub

sed -i -e \
    's/.*GRUB_TERMINAL=.*/GRUB_TERMINAL="serial console"/' \
    /etc/default/grub

sed -i -e \
    's/.*GRUB_SERIAL_COMMAND=.*/GRUB_SERIAL_COMMAND="serial --speed=9600 --unit=0 --word=8 --parity=no --stop=1"/' \
    /etc/default/grub

sed -i -e \
    's/.*GRUB_TIMEOUT_STYLE=.*/GRUB_TIMEOUT_STYLE="hidden"/' \
    /etc/default/grub

sed -i -e \
    's/.*GRUB_HIDDEN_TIMEOUT=.*/GRUB_HIDDEN_TIMEOUT=0/' \
    /etc/default/grub

sed -i -e \
    's/.*GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/' \
    /etc/default/grub

sed -i -e \
    's/.*GRUB_DISABLE_RECOVERY=.*/GRUB_DISABLE_RECOVERY=\"true\"/' \
    /etc/default/grub

# Add include directory should it not exist.
[[ -d /etc/default/grub.d ]] || mkdir -p /etc/default/grub.d

# Disable the GRUB_RECORDFAIL_TIMEOUT.
cat <<'EOF' > /etc/default/grub.d/99-disable-recordfail.cfg
GRUB_RECORDFAIL_TIMEOUT=0
EOF

dracut -f initramfs-$(uname -r).img  $(uname -r)
grub2-mkconfig –o /boot/grub2/grub.cfg

# GRUB_CMDLINE_LINUX[_DEFAULT] did not seem to work directly,
# probably because of GRUB_ENABLE_BLSCFG=true
# grubby --update-kernel=ALL --args="${KERNEL_OPTIONS[*]}"
