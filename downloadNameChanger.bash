#!/bin/bash

#Sets a watch on the users Downloads folder, any time a new file is added if it matches the 
#regex ".*[[:space:]]+\(([0-9]+)\)(\.\w+)*$" (ex. "some_file (1).zip") and renames it by 
#removing the brackets and using an underscore instead of a  space (ex. "some_file_1.zip"). 
#This is for downloads of the same files in chrome (and possibly other browser) to change the default renaming scheme.

directory="/home/$USER/Downloads"   # or whatever you are interested in
inotifywait -m -e create "$directory" |
while read folder eventlist eventfile
do
#    echo "the following events happened in folder $folder:"
#    echo "$eventlist $eventfile"
regex='.*[[:space:]]+\(([0-9]+)\)(\.\w+)*$'
    if [[ "$eventfile" =~ $regex ]]; then
    	#Get the file number it is trying to download with
    	file_number="${BASH_REMATCH[1]}"

    	#Replace the (1) with _1 in the file name
	new_file_name=`echo "$eventfile" | perl -pe 's/[[:space:]]+\(/_/g'`
	new_file_name=`echo "$new_file_name" | perl -pe 's/\)(?=(\.\w+)?$)//g'`

	#Get the next available number
	while [ -f "$directory/$new_file_name" ]; do
		file_number=`expr $file_number + 1`
		new_file_name=`echo "$new_file_name" | perl -pe "s/[0-9]+(?=(\.\w+)*$)/$file_number/g"`
	done

	#Rename the file
	echo "Renaming file $eventfile to $new_file_name"
	mv "$directory/$eventfile" "$directory/$new_file_name"
    fi
done
