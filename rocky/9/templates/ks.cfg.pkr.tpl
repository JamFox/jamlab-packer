## Keyboard layouts
keyboard --vckeymap=${vconsole_keymap} --xlayouts='${keyboard_layout}'

## System language
lang ${language}

## System timezone
timezone ${timezone}

# Install from a CDROM
cdrom

# Use text install
text

# Repo Mirrorlist
#repo --name=AppStream --mirrorlist=https://mirrors.rockylinux.org/mirrorlist?arch=$basearch&repo=AppStream-$releasever

# System authorization
rootpw --iscrypted ${root_password}

## Do not configure the X Window System
skipx

# System bootloader configuration
bootloader --location=mbr %{~ if bootargs != [] } ${ join(" ", bootargs) } %{~ endif }

# Partitioning
%{~ if ks_partitioning_commands != [] }
${ join("\n", ks_partitioning_commands) }
%{~ endif }

# Clear the Master Boot Record
zerombr
# Automatically create partitions using LVM
autopart --nohome --type=lvm


## Network information
network --bootproto=dhcp --device=ens18 --activate
network --hostname=rockytpl

## System services
services --disabled="kdump" --enabled="sshd"

## Firewall
firewall --service=ssh

## SELinux
selinux --enforcing

firstboot --disabled
eula --agreed

reboot

%packages --ignoremissing --excludedocs

@^minimal-environment
openssh-clients
openssh-server
curl
dnf-utils
net-tools
sudo
vim
wget
python3
python3-libselinux
qemu-guest-agent


# unnecessary firmware
-aic94xx-firmware
-alsa-*
-atmel-firmware
-b43-openfwwf
-bfa-firmware
-fprintd-pam
-ipw*-firmware
-ivtv-firmware
-iwl*-firmware
-libertas-usb8388-firmware
-microcode_ctl
-ql*-firmware
-rt61pci-firmware
-rt73usb-firmware
-xorg-x11-drv-ati-firmware
-zd1211-firmware

# misc
-cockpit
-intltool
-quota
%end

%addon com_redhat_kdump --disable
%end

%post
# make sure packer can run provisioners as root
# alternative would be to create a user account
sed -e 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' -i /etc/ssh/sshd_config
%end
