#!/bin/bash

if [ "$#" -ne 2 ]; then
	echo "Wrong number of variables supplied"
	exit 1
fi

image="$1"
name="$2"

image_type=`file "$image"`
image_type="${image_type#*:}"
image_type="$(echo -e "${image_type}" | sed -e 's/^[[:space:]]*//')"
image_type="${image_type%% *}"

if [ "$image_type" != "PNG" ]; then
	if mogrify -format png "$image"; then
		image="${image%.*}.png"
	else
		echo "Could not convert $image to PNG"
		exit 1
	fi
fi

declare -a sizes=("16x16" "32x32" "48x48" "128x128" "256x256")

for size in "${sizes[@]}"; do
	convert "$image" -resize "$size" "/home/$USER/.local/share/icons/hicolor/$size/apps/$name.png"
done