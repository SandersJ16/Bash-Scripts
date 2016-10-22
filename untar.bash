#!/bin/bash

if [ $#  == 0 ]; then
	echo "No File Supplied"

elif [ ${1: -4} == ".tar" ]; then
	
	if [ $# == 2 ]; then
		tar -xvf "$1" -C "$2"
	else
		tar -xvf "$1"
	fi		

elif [ ${1: -7} == ".tar.gz" ] || [ ${1: -4} == ".tgz" ]; then
	if [ $# == 2 ]; then
		tar -xvzf "$1" -C "$2"
	else
		tar -xvzf "$1"
	fi
elif [ ${1: -7} == ".tar.bz" ] || [ ${1: -4} == ".tbz" ] || [ ${1: -5} == ".tbz2" ] || [ ${1: -4} == ".tb2" ] || [ ${1: -8} == ".tar.bz2" ]; then
	if [ $# == 2 ]; then
		tar -xjvf "$1" -C "$2"
	else
		tar -xjvf "$1"
	fi
elif [ ${1: -7} == ".tar.xz" ] || [ ${1: -4} == ".txz" ]; then
	if [ $# == 2 ]; then
		tar -xJf "$1" -C "$2"
	else
		tar -xJf "$1"
	fi
else
	echo "Can not untar"
fi
