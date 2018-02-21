#!/bin/bash

find_type="regex"
additional_grep_args=""
find_limiter="( -type d -printf %p/\n , -type f -print )"
show_colors=true
full_path_search=false

declare -a arguments

while [ "$#" -gt 0 ]; do
    while getopts ":hidfna" opt; do
      case $opt in
        i)
          find_type="iregex"
          additional_grep_args="i"
          ;;

        d)
          find_limiter="-type d -printf %p/\n"
          ;;
        f)
          find_limiter="-type f"
          ;;
        n)
		  show_colors=false
		  ;;
		a)
		  full_path_search=true
		  ;;
        h)
          cat <<EOF
    Search For any folders or files located in the current directory or a subdirectory that contain the regex passed in
    Usage: search [-iadfn] search_string
       -i   Make search case insensitive
       -a   Match on full path instead of just directory or file name
       -d   Display only matching directories
       -f   Display only matching files
       -n   Don't color output
       -h   displays basic help
EOF
          exit 0
          ;;
        \?)
          echo "Invalid option: -$OPTARG" >&2
          exit 1
          ;;
        :)
          echo "Option -$OPTARG requires an argument." >&2
          exit 1
          ;;
      esac
    done
    shift $(($OPTIND - 1)) #remove processed arguments

    # Continue looping through all arguments, store non options in $arguments array
    # This allows us to place options after arguments but still use getopts to process them
    while [[ "$#" -gt 0 ]] && [[ "${1:0:1}" != "-" ]]; do
        arguments=("${arguments[@]}" "$1")
        shift #remove processed arguments
    done
done

# If there were no arguments exit
if [ "${#arguments[@]}" -eq 0 ]; then
	echo "No arguments given"
	exit 1
fi

# Find all file paths and folder paths that match the regex of the first argument
find_command='find . -regextype posix-extended -${find_type} ".*${arguments[0]}.*" ${find_limiter} 2>/dev/null'

# For each argument supplied perform a grep on the results of the seach, limiting results and providing colouring
grep_commands=''
for (( i=0; i<${#arguments[@]}; i++ )); do

	# If an argument ends with a $ then we modify our search so it works for
	if [[ "${arguments[$i]}" == *$ ]]; then
		grep_commands="${grep_commands} | grep -P${additional_grep_args}e \"${arguments[$i]::-1}(?=/?$)\""
	else
		if [[ "$full_path_search" == true ]];then
			grep_commands="${grep_commands} | grep -P${additional_grep_args}e \"${arguments[$i]}\""
		else
			grep_commands="${grep_commands} | grep -P${additional_grep_args}e \"${arguments[$i]}(?=[^/]*/?$)\""
		fi
	fi

	# By default force colour to pass through pipes highlighting all matching parts
	if [[ "$show_colors" == true ]]; then
		grep_commands="${grep_commands} --color=always"
	fi
done

eval "${find_command}${grep_commands}"
