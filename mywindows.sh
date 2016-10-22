#!/bin/sh

mount_point="/media/$USER/windows"
if ! grep -q "[[:space:]]$mount_point[[:space:]]" /proc/mounts; then
    sudo mount -t ntfs /dev/nvme0n1p3 "$mount_point"
fi
cd "$mount_point"/Users/Justin
