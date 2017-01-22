#!/bin/bash

exclude_defaults=true
search_term=""
other_args=""
for input in "$@"; do
  if [[ ! "$input" =~ -.* ]] && [[ -z "$search_term" ]]; then
    search_term="$input"
  elif [[ "$input" == "-v" ]]; then
    exclude_defaults=false
  else
    other_args="$other_args $input"
  fi
done

grep_command="grep -nr . 2>/dev/null --color=always -P $other_args -e $search_term"
if [ $exclude_defaults = true ]; then
  eval "$grep_command | grep -Pve '^[^:]*(\.git|\.tags|\.min\.js|\.mo)'"
else
  eval "$grep_command"
fi