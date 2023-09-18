source "file" "preseed" {
  content = templatefile("${path.root}/templates/preseed.cfg.pkr.tpl", {
    root_password = local.root_password
    country       = var.country
    language      = var.language
    timezone      = var.timezone
    keymap        = var.keymap
    diskname      = local.diskname
  })
  target = "${path.root}/seed/preseed.cfg"
}
