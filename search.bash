#!/bin/bash

find_type="regex"
additional_grep_args=""
find_limiter="( -type d -printf %p/\n , -type f -print )"
show_colors=true
regex_modifier="(?=[^/]*/?$)"

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
		  regex_modifier=""
		  ;;
        h)
          cat <<EOF
    Search For any folders or files located in the current directory or a subdirectory that contain the regex passed in
    Usage: search [-i] search_string
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
    shift $(($OPTIND - 1))


    while [[ "$#" -gt 0 ]] && [[ "${1:0:1}" != "-" ]]; do
        arguments=("${arguments[@]}" "$1")
        shift
    done
done


if [ "${#arguments[@]}" -eq 0 ]; then
	echo "No arguments given"
	exit 1
fi

find_command='find . -regextype posix-extended -${find_type} ".*${arguments[0]}.*" ${find_limiter} 2>/dev/null'

grep_commands=''
for (( i=0; i<${#arguments[@]}; i++ )); do
	grep_commands="${grep_commands} | grep -P${additional_grep_args}e \"${arguments[$i]}${regex_modifier}\""

	if [[ "$show_colors" == true ]]; then
		grep_commands="${grep_commands} --color=always"
	fi
done


eval "${find_command}${grep_commands}"
