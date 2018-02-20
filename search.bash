#!/bin/bash

find_type="regex"
additional_grep_args=""
find_limiter="( -type d -printf %p/\n , -type f -print )"

declare -a arguments

while [ "$#" -gt 0 ]; do
    while getopts ":hidf" opt; do
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
        h)
          cat <<EOF
    Search For any folders or files located in the current directory or a subdirectory that contain the regex passed in
    Usage: search [-i] search_string
       -i   Make search case insensitive
       -d   Display only matching directories
       -f   Display only matching files
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

eval 'find . -regextype posix-extended -${find_type} ".*${arguments[0]}.*" ${find_limiter} 2>/dev/null |grep -P${additional_grep_args}e "${arguments[0]}(?=[^/]*/?$)" --color=auto'
