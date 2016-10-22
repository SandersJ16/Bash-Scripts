#!/bin/bash

if [[ "$1" == *\/* ]]; then
	valgrind --tool=memcheck --leak-check=yes "$1"
else
	valgrind --tool=memcheck --leak-check=yes "./$1"
fi
