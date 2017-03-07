#!/bin/bash

exclude_defaults=true
search_term=""
other_args=""
for input in "$@"; do
  if [[ ! "$input" =~ ^-.* ]] && [[ -z "$search_term" ]]; then
    search_term=`echo "$input" | sed 's/"/\\\"/'`
  elif [[ "$input" == "-v" ]]; then
    exclude_defaults=false
  else
    other_args="$other_args $input"
  fi
done

grep_command="grep -nr . 2>/dev/null --color=always -Pe \"$search_term\" $other_args"
if [ $exclude_defaults = true ]; then
 eval "$grep_command | grep -Eve '^[^:]*(\.git|\.tags|\.min\.js|\.mo|jit-yc\.js)'"
else
  eval "$grep_command"
fi
echo -e "\e[1;36m---------------------------Done---------------------------\e[0m"
