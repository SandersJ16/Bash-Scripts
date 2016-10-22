#!/bin/bash

screen_width=`tput cols` #current width of terminal
min_spaces=4 #minimum number of spaces between file names

ifs_holder=IFS #Record original IFS value
IFS=$'\n' #Change IFS to newline so loops will iterate at newline only and not other whitespace

declare -a colored=() #list of all strings still with color codes
declare -a colorless=() #list of strings without color codes

#Assign input to arrays
while read -t 0.1 file; do
	colored=("${colored[@]}" "$file")
	
	color_removed=`echo $file | sed -r 's/\[[^mK]*(m|K)//g'` #Removes All linux Color Codes from String
	colorless=("${colorless[@]}" "$color_removed")
done

#if no Input given
if [ ${#colored[@]} == 0 ]; then
	echo "No Input"
else
	max_len=0
	folder_count=0

	#Set max_len to the longest String
	#Set folder_count to number of files passed to ccolumn
	for ((i=0;i<${#colorless[@]};i++)); do
		len=${#colorless[$i]}
		let "folder_count += 1"
		if [ $len -gt $max_len ]; then
			max_len=$len
		fi
	done

	let "max_len += min_spaces"
	let "num_columns = screen_width/max_len" #Number of Columns that can fit
	let "rows = (folder_count + (num_columns - 1))/num_columns" #Number of rows needed

	#echo "Max Length: $max_len"
	#echo "Folder Count: $folder_count"
	#echo "Screen Width: $screen_width"
	#echo "Number of Columns: $num_columns"
	#echo "Number of Rows: $rows"
	
	
	for ((i=0;i<$rows;i++)); do
		for ((j=0;j<$num_columns;j++)); do
			let "file_num = i + rows * j" #Iteration through every rowth file ex. if row==7 then for the first loop fil_num will equal 0, 7, 14, etc  
			if [ $file_num -lt $folder_count ]; then
				echo -ne "${colored[$file_num]}"
				length="${#colorless[$file_num]}"
				let "spaces = max_len - length"
				
				#Fill with appropriate spaces
				for ((k=0;k<$spaces;k++)); do
					echo -ne " "
				done
			fi
		done 
		#Start new line
		echo ""
	done
fi
#reset IFS
IFS="$ifs_holder" 
