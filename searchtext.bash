#!/bin/bash

print_grep=false
exclude_defaults=true
grep_options="-P"
search_term=""
other_args=""
last_arg=""

declare -a other_search_terms

for input in "$@"; do
  if [[ ! "$input" =~ ^-.* ]] && [[ -z "$search_term" ]]; then
    search_term=`echo "$input" | sed 's/"/\\\"/'`
  elif [[ "$input" == "-V" ]]; then
    exclude_defaults=false
  elif [[ "$input" == "-i" ]]; then
    grep_options="${grep_options}i"
  elif [[ "$input" == "-v" ]]; then # TODO: Doesn't really work as intended yet
    grep_options="${grep_options}v"
  elif [[ "$input" == "-p" ]]; then
    print_grep=true
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
grep_command="grep -Inr . 2>/dev/null --color=$color ${grep_options} -e \"$search_term\" $other_args"
if [ $exclude_defaults = true ]; then
  #list of directories and file types to exclude by default, will not be excluded if -V flag is used
  grep_command="$grep_command --exclude-dir=.git --exclude-dir=node_modules --exclude=.tags --exclude=\"*.min.js\" --exclude=\"*.mo\" --exclude=jit-yc.js"
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

  grep_command="$grep_command | grep ${grep_options} -e \"${search_term}\" --color=always"
done

if [ $print_grep == true ]; then
  echo "$grep_command"
else
  eval "$grep_command"
fi

echo -e "\e[1;36m---------------------------Done---------------------------\e[0m"
