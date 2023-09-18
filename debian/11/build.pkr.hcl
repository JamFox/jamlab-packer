# a build block invokes sources and runs provisioning steps on them. The
# documentation for build blocks can be found here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/build
build {
  sources = [
    "source.file.preseed",
    "source.proxmox-iso.debian11",
  ]

  provisioner "shell" {
    environment_vars = [
      "BACKPORTS=%{if var.backports}yes%{else}no%{endif}"
    ]
    scripts = [
      "${path.root}/../scripts/05-grub.sh",
      "${path.root}/../scripts/10-sysconfig.sh",
      "${path.root}/scripts/20-repos.sh",
      "${path.root}/../scripts/30-upgrade.sh",
      "${path.root}/scripts/50-cloud-init.sh",
      "${path.root}/../scripts/99-clean.sh",
    ]
  }

  provisioner "file" {
    content = templatefile("${path.root}/../files/50_growpart_lvm.cfg", {
      diskname = local.diskname
    })
    destination = "/etc/cloud/cloud.cfg.d/50_growpart_lvm.cfg"
    only        = ["proxmox-iso.debian11"]
  }

  provisioner "file" {
    content = templatefile("${path.root}/../files/50_override_default_user.cfg", {
      default_username = var.default_username
      ssh_keys         = [var.ssh_key]
    })
    destination = "/etc/cloud/cloud.cfg.d/50_override_default_user.cfg"
    only        = ["proxmox-iso.debian11"]
  }

  provisioner "file" {
    sources = [
      "${path.root}/../files/99_pve.cfg",
    ]
    destination = "/etc/cloud/cloud.cfg.d/"
    only        = ["proxmox-iso.debian11"]
  }

  provisioner "file" {
    source      = "${path.root}/../files/grow_root.sh"
    destination = "/usr/local/sbin/grow_root"
    only        = ["proxmox-iso.debian11"]
  }

  # chmod grow_rootm, remove localhost=debian from hosts, disable root login (cloud-init seems not to work somehow)
  provisioner "shell" {
    inline = [
      "chmod u+x /usr/local/sbin/grow_root",
      "sed -i /debian/d /etc/hosts",
      "passwd -l root",
      "sed -e 's/PermitRootLogin yes/PermitRootLogin no/' -i /etc/ssh/sshd_config",
    ]
  }
}
