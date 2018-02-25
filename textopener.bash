#!/bin/bash

for var in "$@";do
	nohup gnome-open "$var" >>/tmp/nohup.out 2>&1 &
done
