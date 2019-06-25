#!/usr/bin/env bash

PROBABILITY=${1:-10}
ENTITY=${2:-3}
PERIOD=${3:-1}
RECOVER=${4:-10}

while :
do
	workers=`pgrep -f worker.py | xargs`
	coordenators=`pgrep -f coordinator.py | xargs`
	
	case $ENTITY in
		0) procs="" ;;
		1) procs="$workers" ;;
		2) procs="$coordenators" ;;
		3) procs="$workers $coordenators" ;;
		*) procs="" ;;
	esac

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
