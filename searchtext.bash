#!/bin/bash

exclude_defaults=true
search_term=""
other_args=""
last_arg=""

declare -a other_search_terms
for input in "$@"; do
  if [[ ! "$input" =~ ^-.* ]] && [[ -z "$search_term" ]]; then
    search_term=`echo "$input" | sed 's/"/\\\"/'`
  elif [[ "$input" == "-v" ]]; then
    exclude_defaults=false
  elif [[ "$input" =~ -.* ]]; then
    other_args="$other_args $input"
  else
    if [[ "${last_arg:0:1}" == "-" ]] && [[ "${last_arg:0:2}" != "--" ]] && [[ "efmdABCD" =~ .*"${last_arg: -1}".* ]]; then
      other_args="$other_args $input"
    else
      other_search_terms=("${other_search_terms[@]}" "$input")
    fi
  fi
  last_arg="$input"
done


if [ "${#other_search_terms[@]}" -eq 0 ]; then
  color="auto"
else
  color="always"
fi

grep_command="grep -Inr . 2>/dev/null --color=$color -Pe \"$search_term\" $other_args"
if [ $exclude_defaults = true ]; then
  grep_command="$grep_command --exclude-dir=.git --exclude-dir=node_modules --exclude=.tags --exclude=\"*.min.js\" --exclude=\"*.mo\" --exclude=jit-yc.js"
fi

for (( i=0; i<${#other_search_terms[@]}; i++ )); do
    search_term="${other_search_terms[$i]}"
    if [[ "$search_term" =~ "^".* ]];then
      search_term="(?<=[:-]\\x1b\\[m\\x1b\\[K)${search_term:1}"
    fi
    grep_command="$grep_command | grep -Pe \"$search_term(?!(.*(\\x1b\\[[0-9;]*[mGKH])[-:](\\x1b\\[[0-9;]*[mGKH])+\d+(\\x1b\\[[0-9;]*[mGKH])+[-:]))\" --color=always"
done
eval "$grep_command"

#echo -e "\e[1;36m---------------------------Done---------------------------\e[0m"
