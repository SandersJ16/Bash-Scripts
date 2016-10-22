#!/bin/bash

input=`echo "$*" | sed -r 's/\*\*/\^/g'`
echo "$input" =
echo "$input" | bc
