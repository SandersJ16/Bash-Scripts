#!/bin/bash

for input in "$@"; do
	if [[ ! "$input" =~ -.* ]] ; then
		break
	fi
done
if [ -d "$input" ]; then
	/bin/rm -Ivr "$@"
else
	/bin/rm -Iv "$@"
fi