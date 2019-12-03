#!/bin/bash

#------------------------------------------------------------------------------------------------------------
# This script  can be used to take an image and make it available for use as an icon for a linux system.
# It take two arguments, the path to an image and the name you want to give the image
#
# It will then take this image, converts it to a PNG if it is not already, resize it to multiple sizes
# and copy it to your users local icon locations for each size.
#
# ex. bash add_to_local_icons.bash ./custom_sublime_text_image.jpeg "sublime-logo"
#------------------------------------------------------------------------------------------------------------

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
    icon_path="/home/$USER/.local/share/icons/hicolor/$size/apps"
    mkdir -p "$icon_path"
	convert "$image" -resize "$size" "$icon_path/$name.png"
done
