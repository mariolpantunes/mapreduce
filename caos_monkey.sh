#!/usr/bin/env bash

PERIOD=${1:-1}
RECOVER=${2:-10}
PROBABILITY=${3:-10}

while :
do
	workers=`pgrep -f worker.py | xargs`
	coordenators=`pgrep -f coordinator.py | xargs`
	procs="$workers $coordenators"

	for pid in $procs; do
		kill_probability=$((RANDOM % $PROBABILITY))
		echo "$kill_probability ? $pid"
		if [ "$kill_probability" -lt 1 ]; then
			kill -HUP $pid
			echo "Killed pid $pid, giving you 10 sec to recover"
			sleep $RECOVER 
		fi
	done
	sleep $PERIOD
done
