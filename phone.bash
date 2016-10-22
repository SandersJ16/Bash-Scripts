#!/bin/bash

input=$1
input=$(echo $input| tr '[A-Z]' '[a-z]') #Input to Lowercase

possible_phone=$(echo $input | tr -d '[:punct:][:blank:][:alpha:]') #Remove all but Numbers
echo ""
found=0

tokens=()

while read current_line; do 

	unset tokens	
	for words in $(echo $current_line); do
		words=$(echo $words| tr '[A-Z]' '[a-z]')
		tokens=(${tokens[@]} $words) #tokens is an array of each word in the line
	done

	phone_number=$(echo ${tokens[2]} | tr -d '[:punct:][:blank:][:alpha:]') #Current line's phone number
	full_name="${tokens[0]} ${tokens[1]}" 					#Current line's full name
	city=${tokens[(${#tokens[@]} - 1)]} 					#Current line's city
	street_type=$(echo ${tokens[5]} | tr -d '[:punct:]') 			#Current line's street type ex. avenue
	street_address="${tokens[4]} $street_type"				#Current line's street name
	full_street_address="${tokens[3]} $street_address" 			#Current line's street address

	if [ "$possible_phone" == "$phone_number" ] || [ "$input" == "$full_name" ] || [ "$input" == "$city" ] || [ "$input" == "${tokens[0]}" ] || [ "$input" == "${tokens[1]}" ] || [ "$input" == "${tokens[2]}" ] || [ "$input" == "${tokens[4]}" ] || [ "$input" == "$street_type" ] || [ "$input" == "$street_adress" ] || [ "$input" == "$full_street_address" ]; then # if matches any above

		echo $current_line
		found=1
	fi	
done <phonedata.txt #database where information is stored

#if No matches found
if [ $found -eq 0 ]; then
	echo "\"$1\" Not Found"
fi
echo ""
