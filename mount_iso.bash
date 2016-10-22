#!/bin/bash

if [ $# == 1 ]; then
	iso="$1"
	extension="${iso##*.}"
	if [[ "$extension" =~ (iso) ]]; then
		mount_point="/media/iso"
		if ! grep -q "[[:space:]]$mount_point[[:space:]]" /proc/mounts; then
			sudo mount -o loop "$iso" "$mount_point"
			echo "$iso succesfully mounted to $mount_point"
		else
			echo "An ISO is already mounted at $mount_point"
		fi
	else
		echo "File not an ISO"
	fi
else
	echo "Incorrect number of arguments supplied"
fi
