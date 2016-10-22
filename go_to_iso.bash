#!/bin/bash

mount_point="/media/iso"
if ! grep -q "[[:space:]]$mount_point[[:space:]]" /proc/mounts; then
	echo "No ISO is mounted"
else
	cd "$mount_point"
fi
