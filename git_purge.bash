#!/bin/bash

while [ ! -d ".git" ] && [ `pwd` != "/" ]; do
    cd ..
done
path=`pwd`
if [ "$path" == "/" ]; then
    echo "fatal: Not in a git repository (or any of the parent directories): .git"
    exit 1
fi

git fetch --prune --prune-tags > /dev/null


number_of_branches_to_remove=`git branch -r | awk '{print $1}'| grep -Ev -f /dev/fd/0 <(git branch -vv | grep origin) | awk '{print $1}' | wc -l`

if [ $number_of_branches_to_remove -gt 0 ]; then
    git branch -r | awk '{print $1}'| grep -Ev -f /dev/fd/0 <(git branch -vv | grep origin) | awk '{print $1}' | xargs -r -n  1 git branch -d
else
    echo "No Branches Deleted"
fi



