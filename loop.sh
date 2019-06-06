#!/usr/bin/env bash

if [ $# -lt 1 ]; then
	echo "Usage: loop.sh process"
	echo "Example: loop.sh coordinator -f lusiadas.txt"
	exit 0
fi

proc="$1"
shift
args="$@"

while [[ $RV != 0 ]]; do
	python3 $proc.py $args
	RV=$?
	sleep 1
done

