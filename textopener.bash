#!/bin/bash

for var in "$@";do
	gnome-open "$var" & disown
done
