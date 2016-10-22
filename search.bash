#!/bin/bash

case_sensitive=true
declare search_for=()

getOptions()
{	
	for option_string in "$@"; do
		if [[ "$option_string" =~ -.* ]] ; then
			local option=`echo "$option_string" | sed s/-//`
			#if invalid option
			if [[ $option == *[^$accepted_options]* ]]; then 
				echo "-$option is invalid option"
				exit 1
			else
				options=$options$option 
			fi
		else
			search_for+=("$option_string")
		fi
	done
}

setOptions()
{
	local options=""
	local accepted_options="i"
	getOptions "$@"

	if [[ $options == *i* ]]; then
		case_sensitive=false
	fi
}


setOptions "$@"
if [ ${#search_for[@]} != 0 ]; then
	#find . -type d -iname "*$1*" | grep "$1" --color=always
	
	grep_options="P"
	if [ $case_sensitive == false ]; then
		grep_options="iP"
	fi
	
	for search_item in "${search_for[@]}"; do
		if [ ${#search_for[@]} -gt 1 ]; then
			echo ""
			echo -e "\e[1;36m---------------------------$search_item---------------------------\e[0m"
		fi
		
		find . 2>/dev/null -print | grep -$grep_options --color=always "$search_item(?=([^/]*$))"
	done
	echo -e "\e[1;36m---------------------------Done---------------------------\e[0m"
else
	echo "No arguments given"
fi
