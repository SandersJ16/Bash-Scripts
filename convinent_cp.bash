#!/bin/bash

if [ "$#" -eq 2 ] && [ -f "$1" ] && [ $(stat -c%s "$1") -ge 500000 ]; then
    pcp "$@"
else
    call_from_path -x `dirname "${BASH_SOURCE[0]}"` cp -ivr "$@"
fi
