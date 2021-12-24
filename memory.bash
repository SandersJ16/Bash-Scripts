#!/bin/bash

smem --sort=command | while read line; do

    x=$(echo "$line" | awk '{ print $4 }')
    echo "${x[0]}"


done

