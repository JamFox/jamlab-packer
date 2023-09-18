#!/bin/bash

set -eu

# This polyfills cloud-init's inability to resize LVM partitions.
# It autodetects the first partition on the boot drive that is home
# to a PV and grows the associated PV/VG as well as the filesystem.
# Note that the partition is not grown automatically since it might
# be an extended partition, in which case you need to grow both.

disk_name="$(df /boot --output=source | tail -n1 | cut -d'/' -f 3 | grep -oe '[[:alpha:]]*')"
primary_partition=''
volume_group=''
fstype="$(df / --output=fstype | tail -n1 | xargs)"

[[ -n $disk_name ]] || exit 1

for i in {1..9}; do
    info="$(pvs --select pv_name=/dev/$disk_name$i -o vg_name --noheadings | xargs)"
    if [ -n "$info" ]; then
        primary_partition="$disk_name$i"
        volume_group="$info"
        break
    fi
done

[[ -n "$primary_partition" && -n "$volume_group" ]] || exit 1

pvresize "/dev/$primary_partition"
lvextend -l +100%FREE "/dev/$volume_group/root"

if [[ "$fstype" == "xfs" ]]; then
    xfs_growfs -d /
else
    resize2fs "/dev/$volume_group/root"
fi
