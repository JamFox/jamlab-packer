locals {
  iso_url      = "https://releases.ubuntu.com/22.04/ubuntu-22.04.3-live-server-amd64.iso"
  iso_checksum = "a4acfda10b18da50e2ec50ccaf860d7f20b389df8765611142305c0e911d16fd"
}

# Resource Definiation for the VM Template
source "proxmox-iso" "ubuntu22" {
  # Proxmox Connection Settings
  proxmox_url = "https://${var.pm_host}/api2/json"
  username    = "${var.pm_api_username}"
  token       = "${var.pm_api_key}"
  # (Optional) Skip TLS Verification
  insecure_skip_tls_verify = true

  # VM General Settings
  node                 = "${var.pm_node}"
  vm_id                = var.vm_id
  vm_name              = "ubuntu22"
  template_description = "Ubuntu Server 22.04"

  # VM OS Settings
  # (Option 1) Local ISO File
  #iso_file = "local:iso/ubuntu-22.04.1-live-server-amd64.iso"
  # - or -
  # (Option 2) Download ISO
  iso_url          = local.iso_url
  iso_checksum     = local.iso_checksum
  iso_storage_pool = var.iso_storage_pool
  unmount_iso      = true

  # VM System Settings
  qemu_agent = true

  # VM Hard Disk Settings
  scsi_controller = var.scsi_controller

  disks {
    disk_size    = var.disk_size
    storage_pool = var.disk_pool
    type         = var.disk_type
  }

  # VM CPU Settings
  cores = var.cpu_cores

  # VM Memory Settings
  memory = var.memory

  # VM Network Settings
  network_adapters {
    model    = var.nic_model
    bridge   = var.nic_bridge
    firewall = "false"
  }

  # VM Cloud-Init Settings
  cloud_init              = true
  cloud_init_storage_pool = var.cloud_init_pool

  # PACKER Boot Commands
  boot_command = [
    "c<wait5>",
    "<esc><wait>",
    "e<wait>",
    "<down><down><down><end>",
    "<bs><bs><bs><bs><wait>",
    "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<wait>",
    "<f10><wait>"
  ]
  boot_key_interval = "30ms"
  boot_wait         = "5s"

  # PACKER Autoinstall Settings
  http_directory = "http"
  # (Optional) Bind IP Address and Port
  http_bind_address = "172.21.5.87"
  http_port_min     = 8802
  http_port_max     = 8802

  ssh_username = "ubuntu"

  # (Option 1) Add your Password here
  ssh_password = "ubuntu"
  # - or -
  # (Option 2) Add your Private SSH KEY file here
  # ssh_private_key_file = "~/.ssh/id_rsa"

  # Raise the timeout, when installation takes longer
  ssh_timeout = var.ssh_timeout
}

source "qemu" "ubuntu22" {
  # PACKER Boot Commands
  boot_command = [
    "c<wait5>",
    "<esc><wait>",
    "e<wait>",
    "<down><down><down><end>",
    "<bs><bs><bs><bs><wait>",
    "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<wait>",
    "<f10><wait>"
  ]
  boot_key_interval = "30ms"
  boot_wait         = "5s"
  iso_url           = local.iso_url
  iso_checksum      = local.iso_checksum
  output_directory  = "output/ubuntu22"
  shutdown_command  = "sudo /usr/sbin/shutdown -h now"
  cpu_model         = var.cpu_type
  memory            = var.qemu_memory
  accelerator       = var.accelerator
  headless          = true
  disk_size         = var.disk_size
  format            = var.format
  # PACKER Autoinstall Settings
  http_directory = "http"
  # (Optional) Bind IP Address and Port
  #http_bind_address = "172.21.5.87"
  #http_port_min = 8802
  #http_port_max = 8802
  ssh_port               = 22
  ssh_password           = "ubuntu"
  ssh_username           = "ubuntu"
  ssh_timeout            = var.ssh_timeout
  ssh_handshake_attempts = 500
  vm_name                = "packer-ubuntu22-amd64.qcow2"
  net_device             = var.net_device
  disk_interface         = var.disk_interface
}

# Build Definition to create the VM Template
build {

  sources = [
    "source.proxmox-iso.ubuntu22",
    "source.qemu.ubuntu22"
  ]

  # Provisioning the VM Template for Cloud-Init Integration in Proxmox #1
  provisioner "shell" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
      "sudo cloud-init clean",
      "sudo rm /etc/ssh/ssh_host_*",
      "sudo truncate -s 0 /etc/machine-id",
      "sudo sync"
    ]
  }

  # Provisioning the VM Template for Cloud-Init Integration in Proxmox #2
  provisioner "file" {
    source      = "files/99-pve.cfg"
    destination = "/tmp/99-pve.cfg"
  }

  # Provisioning the VM Template for Cloud-Init Integration in Proxmox #3
  provisioner "shell" {
    inline = [
      "sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg",
      "sudo passwd -l root",
      "sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config",
    ]
  }

  provisioner "file" {
    source      = "scripts/30-upgrade.sh"
    destination = "/tmp/30-upgrade.sh"
  }
  provisioner "file" {
    source      = "scripts/99-clean.sh"
    destination = "/tmp/99-clean.sh"
  }

  provisioner "shell" {
    inline = [
      "sudo bash /tmp/30-upgrade.sh",
      "sudo bash /tmp/99-clean.sh",
    ]
  }
}

