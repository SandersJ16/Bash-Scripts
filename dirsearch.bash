#!/bin/bash

dir=$1
i=1

for file in `ls $dir`; do
	if [[ "$file" =~ ^[arstARST]...$ ]]; then
		i=$((i+1))
	fi
done
echo $i
