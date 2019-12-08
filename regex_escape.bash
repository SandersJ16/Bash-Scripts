#!/bin/bash

string_to_clean="$1"

# Note: backslash needs to be first
characters_to_escape='\.^$*+?[]()|/'

for (( i=0; i<${#characters_to_escape}; i++ )); do
    character="\\${characters_to_escape:$i:1}"
    string_to_clean=$(echo "$string_to_clean" | sed -r "s/$character/\\\\$character/g")
done
echo "$string_to_clean"
