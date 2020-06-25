#!/bin/bash

# The version of the grep command that will be used
base_grep_command='grep'
# If the default exclude files should be ignored
exclude_defaults=true
# List of options that grep will be modified with
grep_options="-P"
# If the command should be excuted or printed
echo_grep_command=false
# The primary search term we are looking for
search_term=""
# Additional grep options passed thorugh
other_args=""
# The previously processed argument,
# used to help process current argument when looping through
last_arg=""

# Additional regexes to search for
declare -a other_search_terms

for input in "$@"; do
  if [[ ! "$input" =~ ^-.* ]] && [[ -z "$search_term" ]]; then
    search_term=`echo "$input" | sed 's/"/\\\"/'` # set the search term, escapes double quotes
  elif [[ "$input" == "-V" ]]; then
    exclude_defaults=false
  elif [[ "$input" == "-i" ]]; then
    grep_options="${grep_options}i"
  elif [[ "$input" == "-v" ]]; then # TODO: Doesn't really work as intended yet
    grep_options="${grep_options}v"
  elif [[ "$input" == "-p" ]]; then
    echo_grep_command=true
  elif [[ "$input" =~ ^-.* ]]; then
    other_args="$other_args $input"
  else
    # If the last argument was for one of the command flags "efmdABCD" then
    # assume this argument is the value for that command and not a search term
    if [[ "${last_arg:0:1}" == "-" ]] && [[ "${last_arg:0:2}" != "--" ]] && [[ "efmdABCD" =~ .*"${last_arg: -1}".* ]]; then
      other_args="$other_args $input"
    else
      input=`echo "$input" | sed 's/"/\\\"/'`
      other_search_terms=("${other_search_terms[@]}" "$input")
    fi
  fi
  last_arg="$input"
done

# If we are only searching for one string then use color auto
# otherwise use always to force highlighting of all strings
if [ "${#other_search_terms[@]}" -eq 0 ]; then
  color="auto"
else
  color="always"
fi

# Search all non binary files for any regex matching the first searchterm
# pass any additional command flags to this command as well
grep_command="$base_grep_command -Inr . 2>/dev/null --color=$color ${grep_options} -e \"$search_term\" $other_args"
if [ $exclude_defaults = true ]; then
  #list of directories and file types to exclude by default, will not be excluded if -V flag is used
  declare -a exclude_dirs=(".git" "node_modules" "vendor" "log")
  declare -a exclude_files=(".tags" "*.min.js" "*.mo" "*.po" "jit-yc.js" "*.min.css" "*bundle.js")

  for exclude_dir in "${exclude_dirs[@]}"; do
    grep_command="$grep_command --exclude-dir=\"$exclude_dir\""
  done

  for exclude_file in "${exclude_files[@]}"; do
    grep_command="$grep_command --exclude=\"$exclude_file\""
  done
fi

# If other search terms supplied perform grep on on original results for new search term
for (( i=0; i<${#other_search_terms[@]}; i++ )); do
  search_term="${other_search_terms[$i]}"

  # If search term starts with ^ then replace the carrot with regex look behind for ":{color code}"
  # this regex is to make carrots match where the begging of the line would be
  if [[ "$search_term" =~ ^"^".* ]]; then
    search_term="(?<=[:-]\\x1b\\[m\\x1b\\[K)${search_term:1}"
  fi

  # If search term does not end with a $ then add regex look ahead to make sure that what we are
  # matching is in the file contents and not the file name
  if [[ ! "$search_term" =~ .*"$"$ ]]; then
    search_term="${search_term}(?!(.*(\\x1b\\[[0-9;]*[mGKH])[-:](\\x1b\\[[0-9;]*[mGKH])+\d+(\\x1b\\[[0-9;]*[mGKH])+[-:]))"
  fi

  grep_command="$grep_command | $base_grep_command ${grep_options} -e \"${search_term}\" --color=always"
done

if [ $echo_grep_command == true ]; then
  echo "$grep_command"
else
  eval "$grep_command"
fi

echo -e "\e[1;36m---------------------------Done---------------------------\e[0m"
