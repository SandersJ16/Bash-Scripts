#!/bin/bash

usage() {
  cat <<EOF
Wrapper for grep, search for regex pattern(s) in file(s)
Usage: searchtext [-pVNS] [-f PATH] [GREP_OPTIONS] PATTERN...

Default path is current directory; At least 1 PATTERN must be supplied;
If multiple PATTERNS are supplied all must match a line for it to display;

Examples:
  Search all files in current directory for lines containing text "goodbye" AND "moon"
    searchtext "goodbye" "moon"
  Search foo.bar file for all lines matching regex "hello.*world"
    searchtext "hello.*world" -f foo.bar
  Search files file1.txt and file2.txt for lines containing "test" case-insentively
    searchtext -i "test" -f "file1.txt" -f "file2.txt"  ()

Options:
  -p                          Print grep command that would be run
  -V                          Include all files (by default special files are ignored)
  -N                          Don't show line numbers
  -S                          Suppress text "done" when search completes
  -f PATH                     PATH that will be search
      --help                  Display this help text and exit
Most Grep options supported. Common options are (use grep --help) for all options:
  -i, --ignore-case           Ignore case distinctions
  -v, --invert-match          Select non-matching lines
  -H, --with-filename         Print file name with output lines
  -h, --no-filename           Suppress the file name prefix on output
      --include=FILE_PATTERN  Search only files that match FILE_PATTERN
      --exclude=FILE_PATTERN  Skip files and directories matching FILE_PATTERN
      --exclude-dir=PATTERN   Directories that match PATTERN will be skipped.
Following grep options currently only work when a single PATTERN is supplied:
  -o, --only-matching         Show only the part of a line matching PATTERN
  -L, --files-without-match   Print only names of FILEs with no selected lines
  -l, --files-with-matches    Print only names of FILEs with selected lines
  -B, --before-context=NUM    Print NUM lines of leading context
  -A, --after-context=NUM     Print NUM lines of trailing context
  -C, --context=NUM           Print NUM lines of output context
EOF
}

# The executable that will be used as the grep command
grep_executable='grep'
# location we want to search, search is always recursive. Default is current directory
search_location="."
# If line numbers should be shown in the output
show_line_numbers=true
# Single character flag grep options that will be applied, applied to grep for all search terms if more than
base_grep_options="-P"
# Additional single character flag grep options that will be applied, applied to grep for first search term only
extra_grep_options=""
# Multi dash grep options and single character with argument grep options that will be applied
other_grep_options=""
# If the default exclude files should be ignored
exclude_defaults=true
# If the command should be executed or printed
echo_grep_command=false
# Display completed message on finish of search
display_completed_message=true
# All terms to search for
declare -a search_terms

while [ "$#" -gt 0 ]; do
    OPTIND=1
    while getopts ":ivVSNpf:e:m:d:A:B:C:D:-:" opt "$@"; do
      case $opt in
        i|v)
          base_grep_options="${base_grep_options}${opt}"
          ;;
        V)
          exclude_defaults=false
          ;;
        p)
          echo_grep_command=true
          ;;
        N)
          show_line_numbers=false
          ;;
        f)
          search_location="${OPTARG}"
          ;;
        S)
          display_completed_message=false
          ;;
        e|m|d|A|B|C|D)
          other_grep_options="$other_grep_options -${opt} ${OPTARG}"
          ;;
        -)
          if [ "${OPTARG}" == "help" ]; then
            usage
            exit 0
          fi
          other_grep_options="$other_grep_options --${OPTARG}"
          ;;
        \?)
          #base_grep_options="${base_grep_options}${OPTARG}"
          #if [ -z "$extra_grep_options" ]; then
          #  extra_grep_options="-"
          #fi
          extra_grep_options="${extra_grep_options}${OPTARG}"
          ;;
        :)
          echo "Option -$OPTARG requires an argument." >&2
          exit 1
          ;;
      esac
    done
    shift $(($OPTIND - 1)) #remove processed arguments

    # Continue looping through all arguments, store non options in $search_term array
    # This allows us to place options after search terms but still use getopts to process them
    while [[ "$#" -gt 0 ]] && [[ "${1:0:1}" != "-" ]]; do
        search_term=`echo "$1" | sed 's/"/\\\"/g'` # escape double quotes in regex
        search_terms=("${search_terms[@]}" "${search_term}")
        shift # remove processed search terms
    done
done

if [ "${#search_terms[@]}" -eq 0 ]; then
  echo "Must supply at least 1 search term"
  exit 1
fi


# If we are only searching for one string then use color auto
# otherwise use always to force highlighting of all strings
if [ "${#search_terms[@]}" -gt 1 ]; then
  color="always"
else
  color="auto"
fi

grep_base_options="-Isr"
# Our default is to show line numbers, grep does not have a way
# to override this to false once this option is set so we have created
# our own -N to override it by never setting the -n flag at all
if [ $show_line_numbers == true ]; then
  grep_base_options="${grep_base_options}n"
fi

# Search all non binary files for any regex matching the first search term
# pass any additional command flags to this command as well
grep_command="$grep_executable $grep_base_options $search_location --color=$color ${base_grep_options}${extra_grep_options} -e \"${search_terms[0]}\" $other_grep_options"
if [ $exclude_defaults ==  true ]; then
  #list of directories and file types to exclude by default, will not be excluded if -V flag is used
  declare -a exclude_dirs=(".git" "node_modules" "vendor" "log")
  declare -a exclude_files=(".tags" "*.min.js" "*.mo" "*.po" "jit-yc.js" "*.min.css" "*bundle.js" "*.css.map")

  for exclude_dir in "${exclude_dirs[@]}"; do
    grep_command="$grep_command --exclude-dir=\"$exclude_dir\""
  done

  for exclude_file in "${exclude_files[@]}"; do
    grep_command="$grep_command --exclude=\"$exclude_file\""
  done
fi

# If other search terms supplied perform grep on on original results for new search term
for (( i=1; i<${#search_terms[@]}; i++ )); do
  search_term="${search_terms[$i]}"

  # If search term starts with ^ then replace the carrot with regex look behind for ":{color code}"
  # this regex is to make carrots match where the beginning of the line would be
  if [[ "$search_term" =~ ^"^".* ]]; then
    search_term="(?<=[:-]\\x1b\\[m\\x1b\\[K)${search_term:1}"
  fi

  # If search term does not end with a $ then add regex look ahead to make sure that what we are
  # matching is in the file contents and not the file name
  if [[ ! "$search_term" =~ .*"$"$ ]]; then
    search_term="${search_term}(?!(.*(\\x1b\\[[0-9;]*[mGKH])[-:](\\x1b\\[[0-9;]*[mGKH])+\d+(\\x1b\\[[0-9;]*[mGKH])+[-:]))"
  fi

  grep_command="$grep_command | $grep_executable ${base_grep_options} -e \"${search_term}\" --color=always"
done

# Print or evaluate grep command
if [ $echo_grep_command == true ]; then
  echo "$grep_command"
else
  eval "$grep_command"
  if [ $display_completed_message == true ]; then
    echo -e "\e[1;36m---------------------------Done---------------------------\e[0m"
  fi
fi
