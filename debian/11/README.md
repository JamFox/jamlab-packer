# Debian 11 (Bullseye) Packer Template for Proxmox VE

## Pkrvars

All variables for a specific template are listed in its corresponding `variables.pkr.hcl` file. If your file ends in `.auto.pkrvars.hcl`, it will be autodiscovered by packer, otherwise you will need to specify it with the `-var-file` option when running packer.

### Required

See the [main README](../../README.md) and the [Debian-specific README](../README.md).

### Optional

The following lists Debian 11-specific variables. See the [main README](../../README.md) and the [Debian-specific README](../README.md) for common ones.

```hcl
# Whether to enable Bullseye backports repository
# (cloud-init v22.2 fixes a bug with static routes for single hosts)
# https://github.com/canonical/cloud-init/commit/9a258eebd96aa5ad4486dba1fe86bea5bcf00c2f
backports = true
```
