#!/bin/bash

mount_point="/media/woodwind"
if ! grep -q "[[:space:]]$mount_point[[:space:]]" /proc/mounts; then
    sudo mount.cifs //woodwind/media "$mount_point" -o user=justin
fi
cd "$mount_point"
