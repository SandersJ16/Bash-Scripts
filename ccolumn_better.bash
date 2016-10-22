#!/bin/bash

screen_width=`tput cols` #current width of terminal
min_spaces=2 #minimum number of spaces between file names
file_num=0

ifs_holder=IFS #Record original IFS value
IFS=$'\n' #Change IFS to newline so loops will iterate at newline only and not other whitespace

declare -a colored=() #list of all strings still with color codes
declare -a colorless=() #list of strings without color codes

declare -a row_sizes=()
declare -a max_lengths=()

#Assign input to arrays
while read -t 0.1 file; do #Read Times out after 0.1 seconds if no input
	colored=("${colored[@]}" "$file")
	
	color_removed=`echo "$file" | sed -r 's/\[[^mK]*(m|K)//g'` #Removes All linux Color Codes from String
	colorless=("${colorless[@]}" "$color_removed")
done

file_num=${#colorless[@]}
#if no Input given
if [ ${#colored[@]} != 0 ]; then
	#if output fits with this many rows
	fitted=false
	rows=1
	
	while [ "$fitted" != true ]; do
		
		#Initalize row_sizes to one for each value
		for ((i=0;i<$rows-1;i++)); do
			row_sizes[$i]=0
		done
		#add new line to row_sizes
		row_sizes=("${row_sizes[@]}" 0)
		
		row_holder=$rows #keep track of how many rows there were at start of loop
		
		#For every rowth element
		for ((i=0;i<$file_num;i+=$rows)); do 
			max_len=0
			#Find max length for first column
			for ((j=0;j<$rows;j++)); do
				let "k = i + j"
				if [ $k -lt $file_num ]; then
					len=${#colorless[$k]}
					if [ $len -gt $max_len ]; then
						max_len=$len
					fi
				fi
			done
			let "max_len += min_spaces"
			
			#Get column number
			let "column = i/rows"
			let "columns = column + 1"
			
			#record max length for column
			if [ $columns -gt ${#max_lengths[@]} ]; then
				max_lengths+=("$max_len")
			else 
				max_lengths[$column]=$max_len
			fi
			
			#Test to see if files will fit
			for ((j=0;j<$rows;j++)); do
				let "k = i + j"
				if [ $k -lt $file_num ]; then
					len=${#colorless[$k]}
					let "spaces = max_len - len"
					let "len += spaces"
					let "row_sizes[j]+=len"
					#If files don't fit add another row and break
					if [ ${row_sizes[$j]} -gt $screen_width ]; then
						let "rows += 1"
						break
					fi
				fi
			done
			if [ $rows != $row_holder ]; then #if files didnt' fit
				break
			fi
		done
		if [ $rows == $row_holder ]; then #if files did fit
			fitted=true
		fi
	done
	
	#Display Files
	for ((i=0;i<$rows;i++)); do #For every row
		for ((j=0;j<${#max_lengths[@]};j++)); do #for every column
			let "file = i + rows * j" #Iteration through every rowth file ex. if row==7 then for the first loop fil_num will equal 0, 7, 14, etc  
			if [ $file -lt $file_num ]; then
				echo -ne "${colored[$file]}"
				length="${#colorless[$file]}"
				max_column_length="${max_lengths[$j]}"
				let "spaces = max_column_length - length"
				
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
