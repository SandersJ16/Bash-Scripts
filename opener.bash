#!/bin/bash

for var in "$@";do
	nohup xdg-open "$var" >>/tmp/nohup.out 2>&1 &
done
