# Packer Builds

Packer IaC templates for building cloud images and templates.

"Inspired" by [packer-proxmox-templates](https://github.com/lkubb/packer-proxmox-templates) 

Builders used: 

- [Packer QEMU Builder](https://www.packer.io/docs/builders/qemu)
- [Packer Proxmox ISO Builder](https://www.packer.io/plugins/builders/proxmox/iso)

## Template status table

**Complete** - template is implemented and conceptually in a finished state. May or may not contain bugs and unoptimal code.

**Proxmox** - template is implemented and tested to produce working VM template in Proxmox.

**QEMU** - template is implemented and tested to produce working VM template using QEMU builder for uploading to OpenStack.

| Template  | Complete | Proxmox | QEMU | Notes | 
| --------- | -------- | ------- | ----------- | ----- |
| Rocky 9   | ✔️      | ✔️      | ✔️        | Scripts unconfirmed to be optimal, but template build succeeds | 
| Debian 11 |  ✔️     | ✔️      | ❌        | -.- |
| Debian 12 |  ✔️     | ✔️      | ❌        | -.- |
| Ubuntu 22 | ✔️      | ✔️      | ✔️        | -.- |

## Setup

### PVE Packer User

You will need a dedicated user account for Packer.
The following commands add one with the required privileges [[Source](https://github.com/hashicorp/packer/issues/8463#issuecomment-726844945)]:

```bash
pveum useradd packer@pve
pveum passwd packer@pve
pveum roleadd Packer -privs "VM.Allocate VM.Clone VM.Config.CDROM VM.Config.CPU VM.Config.Cloudinit VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Monitor VM.Audit VM.PowerMgmt Datastore.AllocateSpace Datastore.Allocate Datastore.AllocateSpace Datastore.AllocateTemplate Datastore.Audit Sys.Audit VM.Console"
#pveum role modify Packer -privs "VM.Allocate VM.Clone VM.Config.CDROM VM.Config.CPU VM.Config.Cloudinit VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Monitor VM.Audit VM.PowerMgmt Datastore.AllocateSpace Datastore.Allocate Datastore.AllocateSpace Datastore.AllocateTemplate Datastore.Audit Sys.Audit VM.Console"
pveum aclmod / -user packer@pve -role Packer
```

### PVE API Key

You can add an API key for this user as well. Suppose the key's label is `packer`, `pm_api_username` will be `packer@pve!packer`.

## Pkrvars

All variables for a specific template are listed in its corresponding `variables.pkr.hcl` file. If your file ends in `.auto.pkrvars.hcl`, it will be autodiscovered by packer, otherwise you will need to specify it with the `-var-file` option when running packer.

### Required variables

Packer requires some variables to be able to connect to Proxmox. These are valid for all templates.

Note: Those are sensitive and should not be checked into version control! As with all Packer variables, you can leave them out of your var file completely and specify them as environment variables (`PKR_VAR_pm_host`, `PKR_VAR_pm_api_username`, `PKR_VAR_pm_api_key`, ...).

```hcl
# Proxmox API host domain or IP address. Needs to be accessible with https.
pm_host = "pve1.lan:8006"
# (OPTIONAL) HTTP IP, if different from the API host, might need to be specified as VM might not have access to all networks that PVE HTTP serves on.
pm_http_address = "172.1.2.3"
# Proxmox API username. When using API key, the format would be e.g. 'packer@pve!packer'.
pm_api_username = "packer@pve!packer"
# Proxmox API key. Either this or pm_api_password is required.
pm_api_key = "0a1b2c3d-4e5f-678a-9b0c1-d2e3f4a5b6c7"
# Proxmox API password. Either this or pm_api_key is required.
pm_api_password = null
# The target node the template will be built on.
pm_node = "pve1"
# ssh key of default admin user
ssh_key = "ssh-dsa ..."
```

`ssh_key` is the only one required for all templates. The rest are required for Proxmox templates, but not for QEMU templates.

API token can be generated in the UI from `Datacenter` tab from `Permissions > API Tokens` menu and then from the button `Add`.

Set up sensitive PVE connection variables using `pve.hvl.sample` as a reference.

### Optional variables

Optional variables vary by the exact template you're building, but the following ones should be supported by all:

```hcl
# Specify OS version to build. Debian and Rocky only.
# For the latest Debian release, if you don't have a local ISO,
# make sure the OS version specified below is the most recent one.
os_version = "11.7.0"

# If you have a local ISO, specify it here.
# iso_file = "local:iso/debian-11.7.0-amd64-netinst.iso"
# If you have a local ISO, specify its checksum here.
# iso_checksum = "c685b85cf9f248633ba3cd2b9f9e781fa03225587e0c332aef2063f6877a1f0622f56d44cf0690087b0ca36883147ecb5593e3da6f965968402cdbdf12f6dd74"
# Whether to skip validating the API host TLS certificate.
pm_skip_tls_verify = true

# Whether to attach a cloud-init CDROM drive to the built template.
cloud_init = true
# The storage pool for the cloud-init CDROM.
cloud_init_pool = "thpl"
# The VM ID used for the build VM and the built template.
vm_id = 1000
# Number of CPU cores for the VM.
cpu_cores = 2
# CPU type to emulate. Best performance: 'host'.
cpu_type = "host"
# Megabytes of memory to associate with the VM.
memory = "2048"
# The storage pool for the default disk.
disk_pool = "thpl"
# The disk size of the default disk.
disk_size = "5G"
# The type of the default disk: 'scsi', 'sata', 'virtio', 'ide'.
disk_type = "virtio"
# The bridge the default NIC is attached to.
nic_bridge = "vmbr0"
# Whether to enable the PVE firewall for the default NIC.
nic_firewall = false
# The model of the default NIC.
nic_model = "virtio"
# The VGA type: cirrus, none, qxl, qxl2, qxl3, qxl4, serial0, serial1, serial2, serial3, std, virtio, vmware
vga_type = "serial0"
# VGA memory in MiB. Note: this is superfluous when using a serial console.
vga_memory = 64
# List of serial ports attached to the virtual machine (max 4).
# Either host device (`/dev/ttyS0`) or `socket`.
serial_ports = ["socket"]

# The default admin username.
default_username = "user"
# The system language
language = "en"
# The system timezone
timezone = "Europe/London"

# A root password to use for provisioning, best to leave it autogenerated by not specifying it
root_password = "hunter1"
```

Note that for some templates (e.g. Debian), when building the latest major stable release without specifying a local ISO, `os_version` **must** specify the correct latest version since only this one will be available from the latest repo.

## Usage

Note: Packer should be run on the Proxmox host itself.

### Installing modules

To install modules and initialize the template, run:

```bash
packer init -upgrade .
```

### Validation

You can validate your configuration by running:

```bash
packer validate -var-file my.pkrvars.hcl .
```

This should output `The configuration is valid.`.

NOTE: Double check storage pool names (`disk_pool` vars), they have to match the pools set up in PVE.

### Building

Having done all that configuration, building the template is easy:

```bash
# For this example, the cwd is `rocky/9`.
packer build -var-file ~/pve.hcl .
```

To limit to specific sources:

```bash
packer build -only='file.kickstart-qemu' -var-file ~/pve.hcl .
```

To run with verbose output:

```bash
PACKER_LOG=1 packer build -var-file ~/pve.hcl .
```

With log output to a file:

```bash
PACKER_LOG_PATH="packerlog.txt" PACKER_LOG=1 packer build -var-file ~/pve.hcl .
```

If you have set an explicit ID and a previous artifact is still present, you will need to delete it manually or use the -force flag (requires plugin version 1.1.2) to regenerate your template.

```bash
packer build -force -var-file my.pkrvars.hcl .
```

### Cloud-init

Cloud-init is for post-installation configuration and should be enabled in packer configuration with the variable `cloud_init` set to true and then the cloud-config file copied using the file provisioner to `/etc/cloud/cloud.cfg`.

Cloud-init is used for initial machine configuration like creating users, installing packages, custom scripts or preseeding `authorized_keys` file for SSH authentication. Read more about this in [cloud-init documentation](https://cloudinit.readthedocs.io/en/latest/).

#### Bootcmd and Autogrow Caveats

- Runtime configuration is drawn from multiple sources. If more than one is available, the one with the highest priority is selected, [no merging is applied](https://github.com/canonical/cloud-init/blob/fca5bb77c251bea6ed7a21e9b9e0b320a01575a9/cloudinit/sources/DataSourceNoCloud.py#L363-L380). There is a fallback to a seed directory commonly found in `/var/lib/cloud/seed/nocloud`.
- I'm not entirely sure whether an existing `vendor-data` seed will be preserved when a higher priority datasource does not expose one since Proxmox always presents one, even if it has not been configured ([in that case it's empty](https://github.com/proxmox/qemu-server/blob/d8a7e9e881e29c899920657f98a0047d9d63abed/PVE/QemuServer/Cloudinit.pm#L490-L505)).
- Multiple separate source trees exist (relevant here: `user-data`, `vendor-data`, `cfg`). If one root key (eg `bootcmd`) is found in multiple sources, again the one with the highest priority is selected, no merging is applied (`user-data` having the highest). Merging configuration only works inside one tree.

All templates are preconfigured to automatically grow the root partition (via `cloud.cfg`, see `seed/cloud-init.sh`). Since `cloud-init` does not support growing LVM partitions atm, it needs to set a `bootcmd`. The combination of both behaviors above results in a tradeoff for this template:

- If you want to set `bootcmd` in your user-data, it will overwrite the preconfigured commands and the **volume will not grow automatically**. There is no workaround for this behavior inside the scope of `cloud-init` and this packer template alone since a seed for `user-data` would be disregarded anyway once Proxmox presents its configuration. Fix by including the relevant commands in your userdata.
