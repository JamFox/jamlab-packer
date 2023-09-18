# Rocky Linux Packer Templates

To run only for Proxmox use following flag `-only=file.kickstart-proxmox,proxmox-iso.rocky9`

To run only for QEMU use following flag `-only=file.kickstart-qemu,qemu.rocky9`

## Pkrvars

All variables for a specific template are listed in its corresponding `variables.pkr.hcl` file. If your file ends in `.auto.pkrvars.hcl`, it will be autodiscovered by packer, otherwise you will need to specify it with the `-var-file` option when running packer.

### Required

See the [main README](../README.md).

### Optional

The following lists Rocky Linux-specific variables. See the [main README](../README.md) for common ones.

```hcl
# The X (keyboard) layout to use, see man setxkbmap
keyboard_layout = "us"
# The VConsole keymap to use, see `man setxkbmap`
vconsole_keymap = "us"
# Optional Kernel boot arguments to configure.
# The following defaults ensure compatibility with a PVE serial terminal
bootargs = [
    "systemd.journald.forward_to_console=1",
    "console=ttyS0,38400",
    "console=tty1",
]
```

## Kickstart File

For automation of Rocky Linux installation, a [Kickstart](https://en.wikipedia.org/wiki/Kickstart_(Linux)) file is required. A default (templated) one is provided.

## References

* https://docs.rockylinux.org/guides/automation/templates-automation-packer-vsphere/
* https://github.com/runter-vom-mattenwagen/proxmox-packer/tree/main/rocky
* https://github.com/dustinrue/proxmox-packer/tree/main/rocky9
* https://github.com/it-pappa/Packer-Proxmox/tree/master/Rocky/rocky9
* https://github.com/clayshek/homelab-monorepo/tree/main/packer/rocky/8.5
* https://github.com/sdhibit/packer-proxmox-templates/tree/main/rocky-8-amd64
* https://github.com/DanHam/packer-virt-sysprep
