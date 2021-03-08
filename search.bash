#!/bin/bash

find_type="regex"
additional_grep_args=""
find_limiter='-type d -printf "%p/\n" , -type f -print'
show_colors=true
full_path_search=false
exclude_special_folders_content=true
print_command=false

declare -a arguments

while [ "$#" -gt 0 ]; do
    while getopts ":hidfnapA" opt; do
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
        A)
          exclude_special_folders_content=false
          ;;
        p)
          print_command=true
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
       -A   Match all file in all subdirectories (don't ignore special directories)
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
find_argument="${arguments[0]}"

# Replace trailing $ with $ or forward slash (grep will take over from there)
if [[ "${find_argument}" == *$ ]]; then
    find_argument="${find_argument::-1}(/|$)"
fi

# Replace ^ with forward slash (grep will take over from there)
if [[ "${find_argument}" == ^* ]]; then
    find_argument="/${find_argument:1}"
fi

# Special folders that should be exclude from the
find_exclude=""
if [[ "$exclude_special_folders_content" == true ]]; then
    special_folders=(".git")
    for special_file in "${special_folders[@]}"; do
       find_exclude=`printf "%s -not -path \"*/%s/*\"" "${find_exclude}" "${special_file}"`
    done
fi

find_command="find . -regextype posix-extended -${find_type} \".*${find_argument}.*\" ${find_exclude} ${find_limiter} 2>/dev/null"

# For each argument supplied perform a grep on the results of the seach, limiting results and providing colouring
grep_commands=''
for (( i=0; i<${#arguments[@]}; i++ )); do
    argument="${arguments[$i]}"

    if [[ "$full_path_search" == true ]]; then
        if [[ "${argument}" == *$ ]]; then
            argument="${argument::-1}"
            regex_modifer="(?=/|$)"
        else
            regex_modifer=""
        fi
    else
        if [[ "${argument}" == *$ ]]; then
            argument="${argument::-1}"
            regex_modifer="(?=/?$)"
        else
            regex_modifer="(?=[^/]*/?$)"
        fi
    fi

    # If an argument ends with
    if [[ "${argument}" == ^* ]]; then
        argument="(?<=/)${argument:1}"
    fi

    grep_commands="${grep_commands} | grep -P${additional_grep_args}e \"${argument}${regex_modifer}\""

    # By default force colour to pass through pipes highlighting all matching parts
    if [[ "$show_colors" == true ]]; then
        grep_commands="${grep_commands} --color=always"
    fi
done

if [ $print_command == true ];then
  echo "${find_command}${grep_commands}"
else
  eval "${find_command}${grep_commands}"
fi
