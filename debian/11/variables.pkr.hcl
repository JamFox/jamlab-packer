# -- Proxmox variables -- #

variable "pm_host" {
  type        = string
  description = "Proxmox API host domain or IP address. Needs to be accessible with https."
}

variable "pm_api_username" {
  type        = string
  description = "Proxmox API username. Example: 'packer@pve', 'root@pam'. When using API key: 'packer@pve!packer_api_key_label'."
}

variable "pm_api_password" {
  type        = string
  sensitive   = true
  default     = null
  description = "Proxmox password for the API user. Either this or pm_api_key is required."
}

variable "pm_api_key" {
  type        = string
  sensitive   = true
  default     = null
  description = "Proxmox API key for the API user. Either this or pm_api_password is required."
}

variable "pm_node" {
  type        = string
  description = "The target node the template will be built on."
}

variable "pm_skip_tls_verify" {
  type        = bool
  default     = false
  description = "Whether to skip validating the API host TLS certificate."
}

variable "pm_http_address" {
  type    = string
  default = null
}
# -- General variables -- #

variable "ssh_timeout" {
  type        = string
  default     = "15m"
  description = "How long to wait for an SSH connection before cancelling (without QEMU guest agent, this is how long the build can take)."
}

variable "os_version" {
  type        = string
  default     = "11.7.0"
  description = "Latest version of the Debian CD netinstaller ISO. Unnecessary when specifying iso_file and iso_checksum."
}

variable "iso_checksum" {
  type        = string
  default     = null
  description = "The checksum for iso_file when it is specified. Otherwise, leave the default and make sure the debian version is correct."
}

variable "iso_file" {
  type        = string
  default     = null
  description = "By default, this fetches the latest installer online. If you have a local ISO, specify it here like: 'local:iso/debian-11.2.0-amd64-netinst.iso'. Specify iso_checksum as well."
}

variable "iso_storage_pool" {
  type        = string
  default     = "local"
  description = "When not specifying a local ISO, it will be downloaded from official sources. The target storage needs to be specified here. Packer user needs 'Datastore.AllocateTemplate' privileges."
}

# -- Template variables -- #

variable "cloud_init" {
  type        = bool
  default     = true
  description = "Whether to attach a cloud-init CDROM drive to the built template."
}

variable "cloud_init_pool" {
  type        = string
  default     = "thpl-storage"
  description = "The storage pool for the cloud-init CDROM. Should default to the storage pool of the boot device, but seems flaky if unspecified."
}

variable "vm_id" {
  type        = number
  default     = 2011
  description = "The VM ID used for the build VM and the built template."
}

variable "cpu_cores" {
  type        = number
  default     = 2
  description = "Number of CPU cores for the VM."
}

variable "cpu_type" {
  type        = string
  default     = "host"
  description = "CPU type to emulate. Best performance: 'host'."
}

variable "memory" {
  type        = number
  default     = 2048
  description = "Megabytes of memory to associate with the VM."
}

variable "bios" {
  type        = string
  default     = "seabios"
  description = "Choose the machine BIOS: 'ovmf', 'seabios'."

  validation {
    condition     = contains(["ovmf", "seabios"], var.bios)
    error_message = "The bios configuration is invalid."
  }
}

variable "machine" {
  type        = string
  default     = "i440fx"
  description = "Choose the machine type: 'i440fx', 'q35'."

  validation {
    condition     = contains(["i440fx", "q35"], var.machine)
    error_message = "The machine type is invalid."
  }
}

variable "scsi_controller" {
  type        = string
  default     = "virtio-scsi-single"
  description = "The SCSI controller model to emulate: lsi, lsi53c810, virtio-scsi-pci, virtio-scsi-single, megasas, pvscsi."

  validation {
    condition     = contains(["lsi", "lsi53c810", "virtio-scsi-pci", "virtio-scsi-single", "megasas", "pvscsi"], var.scsi_controller)
    error_message = "The SCSI controller model is invalid."
  }
}

# -- Template disk variables -- #

variable "disk_pool" {
  type        = string
  default     = "thpl-storage"
  description = "The storage pool for the default disk."
}

variable "disk_size" {
  type        = string
  default     = "20G"
  description = "The disk size of the default disk."
}

variable "disk_cache_mode" {
  type        = string
  default     = "none"
  description = "How to cache operations to the default disk. Can be 'none', 'writethrough', 'writeback', 'unsafe' or 'directsync'."

  validation {
    condition     = contains(["none", "writethrough", "writeback", "unsafe", "directsync"], var.disk_cache_mode)
    error_message = "The disk cache mode is invalid."
  }
}

variable "disk_format" {
  type        = string
  default     = "raw"
  description = "The format of the default disk: 'raw', 'cow', 'qcow', 'qed', 'qcow2', 'vmdk', 'cloop'."

  validation {
    condition     = contains(["raw", "cow", "qcow", "qed", "qcow2", "vmdk", "cloop"], var.disk_format)
    error_message = "The default disk format is invalid."
  }
}

variable "disk_io_thread" {
  type        = bool
  default     = false
  description = "Create one I/O thread per storage controller, rather than a single thread for all I/O. Requires virtio-scsi-single controller and a scsi or virtio disk."
}

variable "disk_type" {
  type        = string
  default     = "scsi"
  description = "The type of the default disk: 'scsi', 'sata', 'virtio', 'ide'."

  validation {
    condition     = contains(["scsi", "sata", "virtio", "ide"], var.disk_type)
    error_message = "The default disk type is invalid."
  }
}

# -- Template NIC variables -- #

variable "nic_bridge" {
  type        = string
  default     = "vmbr0"
  description = "The bridge the default NIC is attached to."
}

variable "nic_firewall" {
  type        = bool
  default     = false
  description = "Whether to enable the PVE firewall for the default NIC."
}

variable "nic_model" {
  type        = string
  default     = "virtio"
  description = "The model of the default NIC."

  validation {
    condition     = contains(["rtl8139", "ne2k_pci", "e1000", "pcnet", "virtio", "ne2k_isa", "i82551", "i82557b", "i82559er", "vmxnet3", "e1000-82540em", "e1000-82544gc", "e1000-82545em"], var.nic_model)
    error_message = "The default NIC model is invalid."
  }
}

variable "nic_vlan" {
  type        = string
  default     = null
  description = "The VLAN tag the default bridge uses. Leave empty for untagged."
}

variable "nic_queues" {
  type        = number
  default     = 0
  description = "Number of packet queues to be used on the default NIC. For routers, reverse proxies or busy HTTP servers. Requires virtio network adapter."
}

# variable nics {
#   type = list(object({
#       bridge = string
#       model = string
#       vlan = string
#       queues = number
#     }))
#   default = [
#     {
#       bridge = "vmbr0"
#       model = "virtio"
#       vlan = ""
#       queues = 0
#     }
#   ]
# }

# -- vga / serial -- #

variable "vga_type" {
  type = string
  # https://gist.github.com/KrustyHack/fa39e509b5736703fb4a3d664157323f#prepare-cloud-init-templates
  # "We also want to configure a serial console and use that as display. Many Cloud-Init images rely on that, because it is an requirement for OpenStack images."
  default     = "std"
  description = "The type of display to virtualize. Options: cirrus, none, qxl, qxl2, qxl3, qxl4, serial0, serial1, serial2, serial3, std, virtio, vmware."
  validation {
    condition     = contains(["cirrus", "none", "qxl", "qxl2", "qxl3", "qxl4", "serial0", "serial1", "serial2", "serial3", "std", "virtio", "vmware"], var.vga_type)
    error_message = "The VGA type is invalid."
  }
}

variable "vga_memory" {
  type        = number
  default     = 64
  description = "Sets the VGA memory (in MiB). Has no effect with serial display type."
}

variable "serial_ports" {
  type        = list(string)
  default     = ["socket"]
  description = "List of serial ports attached to the virtual machine (max 4). Either host device (`/dev/ttyS0`) or `socket`."
}

# -- cloud-init defaults -- #

variable "default_username" {
  type        = string
  default     = "debian"
  description = "The name of the default admin user created by cloud-init: has passwordless sudo, ssh pubkey auth."
}

variable "ssh_key" {
  type        = string
  description = "A single SSH pubkey for the default user's authorized_keys. Required since the template will be locked down."
}

variable "backports" {
  type        = bool
  default     = true
  description = "Activate Bullseye backports repository."
}

# -- OS settings -- #
variable "root_password" {
  type        = string
  sensitive   = true
  default     = null
  description = "The password of the root user account, which will be disabled after setup. If unspecified, will generate a random one."
}

variable "language" {
  type        = string
  default     = "en"
  description = "The system language to set. Two letters, lower case."
}

variable "country" {
  type        = string
  default     = "US"
  description = "The country to set. Two letters, upper case."
}

variable "keymap" {
  type        = string
  default     = "us"
  description = "The X (keyboard) layout to use, see man setxkbmap."
}

variable "timezone" {
  type        = string
  default     = "UTC"
  description = "The timezone to set, like Europe/London."
}
