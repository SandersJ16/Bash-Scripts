#!/bin/bash

run=false
if [ $# == 2 ] && [ $1 == "-r" ]; then
	run=true
fi

if [ $# == 1 ] || [ $run == true ]; then
	program="$1"

	if [ $run == true ]; then
		program="$2"
	fi
	filename=`echo "$program"|sed 's/\.[^.]*$//'`
	extension="${program##*.}"
	compiled=true
	if [[ "$extension" =~ (cpp|cxx) ]]; then
		`g++ --std=c++11 -g -o "$filename" "$program" -Wall -Wextra`
	elif [[ "$extension" =~ cs ]]; then
		`mcs "$program"`
	elif [[ "$extension" =~ c ]]; then
		`gcc -g -o "$filename" "$program"`
	elif [[ "$extension" =~ java ]]; then
		`javac -g "$program"`
	else
		echo "Can't Compile"
		compiled=false
	fi

else
		echo "Incorrect Amount of Arguments"
fi
if [ $run == true ] && [ $compiled == true ]; then
	if [[ "$extension" =~ cs ]]; then
		executable="${filename}.exe"
		mono "$executable"
	elif [[ "$extension" =~ java ]]; then
		if [[ -f  "${filename^}.class" ]] ; then
			java "${filename^}"
		fi
	else
		./"$filename"
	fi
fi
