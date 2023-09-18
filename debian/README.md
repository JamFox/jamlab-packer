# Debian Packer Template for Proxmox

## Pkrvars

All variables for a specific template are listed in its corresponding `variables.pkr.hcl` file. If your file ends in `.auto.pkrvars.hcl`, it will be autodiscovered by packer, otherwise you will need to specify it with the `-var-file` option when running packer.

### Required

See the [main README](../README.md).

### Optional

The following lists Debian-specific variables. See the [main README](../README.md) for common ones.

```hcl
# The system country
country = "UK"
# The system kemap
keymap = "us"
```

## Preseed File

Preseeding provides a way to answer questions asked during the installation process without having to manually enter the answers while the installation is running. Read more about this method in the [preseed documentation](https://wiki.debian.org/DebianInstaller/Preseed).

To automate the Debian ISO netinstaller setup, a `preseed.cfg` file is required. A default (templated) one is provided. If you want to customize this template, see the official docs ([12](https://preseed.debian.net/debian-preseed/bookworm/amd64-main-full.txt) [11](https://preseed.debian.net/debian-preseed/bullseye/amd64-main-full.txt)) for a detailed description of all possible options.

## Flow

This is a short overview of the build steps:

1. Downloads ISO if no local one was specified
2. Creates VM as specified
3. Uses preseed.cfg to automate the installation of Debian. Note:

    * adds necessary packages: `qemu-guest-agent`, `cloud-init`, `vim` (!)
    * adds `root` user with password `packer`
    * allows ssh password auth for `root` (temporarily for provisioning)

4. Configures grub (adds `console=ttyS0`, `elevator=none`, no timeout)
5. Adds sysconfig (`vm.swappiness = 1`)
6. Updates & upgrades system, cleans cloud-init and apt cache
7. Sets basic cloud-init config:

    * by default mostly Debian default with some changes (see `scripts/cloud-init.sh`)
    * possibility to change the default admin username
    * ssh key setup for default admin user
    * Proxmox specifics

8. Locks root account
9. Prohibits ssh root login
10. Shuts down VM and converts it to a template

When logging in for the first time, you should set a password for your user (`sudo passwd <username>` is needed) and remove passwordless sudo.
