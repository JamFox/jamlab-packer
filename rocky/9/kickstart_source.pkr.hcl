source "file" "kickstart-proxmox" {
  content = templatefile("${path.root}/templates/ks.cfg.pkr.tpl", {
    root_password   = bcrypt(local.root_password, 6)
    language        = var.language
    timezone        = var.timezone
    vconsole_keymap = var.vconsole_keymap
    keyboard_layout = var.keyboard_layout
    diskname        = local.diskname
  bootargs = [
    "--boot-drive=${local.diskname}",
    "--append=\"systemd.journald.forward_to_console=1 console=ttyS0,38400 console=tty1\"",
  ]
  ks_partitioning_commands  = [
    "clearpart --none --initlabel --drives=${local.diskname}",
    "ignoredisk --only-use=${local.diskname}",
  ]
  })
  target = "${path.root}/seed/ks-proxmox.cfg"
}

source "file" "kickstart-qemu" {
  content = templatefile("${path.root}/templates/ks.cfg.pkr.tpl", {
    root_password   = bcrypt(local.root_password, 6)
    language        = var.language
    timezone        = var.timezone
    vconsole_keymap = var.vconsole_keymap
    keyboard_layout = var.keyboard_layout
    diskname        = local.diskname
    bootargs        = var.bootargs
    ks_partitioning_commands = var.ks_partitioning_commands
  })
  target = "${path.root}/seed/ks-qemu.cfg"
}
