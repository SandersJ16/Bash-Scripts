#!/bin/bash

while [ ! -d ".git" ] && [ `pwd` != "/" ]; do
    cd ..
done
path=`pwd`
if [ "$path" == "/" ]; then
    echo "fatal: Not a git repository (or any of the parent directories): .git"
    exit 1
fi
echo "Generating CTags in file $path/.tags"
ctags -R -o ".tags" * 2>/dev/null
echo "Ctags Generated"
