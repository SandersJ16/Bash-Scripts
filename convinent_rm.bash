#!/bin/bash

for input in "$@"; do
	if [[ ! "$input" =~ -.* ]] ; then
		break
	fi
done
if [ -d "$input" ]; then
	call_from_path -x `dirname "${BASH_SOURCE[0]}"` rm -r "$@"
else
	call_from_path -x `dirname "${BASH_SOURCE[0]}"` rm "$@"
fi
