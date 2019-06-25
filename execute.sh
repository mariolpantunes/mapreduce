#!/usr/bin/env bash

COORDINATORS=1
WORKERS=1
MONKEY=0
KILL_PROBABILITY=0
ENTITY=0
FILE="raposa_e_as_uvas.txt"

while getopts hc:w:mk:e:f: opt; do
    case $opt in
    h)
        echo -e "Usage: execute [OPTIONS] -f <FILE>"
        echo -e "Runs the Map/Reduce project from CD 2019"
        echo -e "  -h        Display this help message."
        echo -e "  -c        Define the number of Cordinators (1)."
        echo -e "  -w        Define the number of Workers (1)."
        echo -e "  -m        Turn Chaos Monkey scrip On/Off (0)."
        echo -e "  -k        Kill probability for Chaos Monkey 0(0%)/10(10%)/2(50%) (0)."
        echo -e "  -e        Which entity is killed by Chaos Monkey 0/1/2/3 (0)."
        echo -e "  -f        Which ext file to read and process ($FILE)."
        exit 0
    ;;
    c ) COORDINATORS=$OPTARG 
    ;;
    w )  WORKERS=$OPTARG
    ;;
    m ) MONKEY=1
    ;;
    k ) KILL_PROBABILITY=$OPTARG
    ;;
    e ) ENTITY=$OPTARG
    ;;
    f ) FILE=$OPTARG
    ;;
    \? )
        echo -e "Invalid option: $OPTARG" 1>&2
        echo -e "" 1>&2
        echo -e "Usage: execute [OPTIONS] -f <FILE>" 1>&2
        echo -e "Runs the Map/Reduce project from CD 2019" 1>&2
        echo -e "  -h        Display this help message." 1>&2
        echo -e "  -c        Define the number of Cordinators (1)." 1>&2
        echo -e "  -w        Define the number of Workers (1)." 1>&2
        echo -e "  -m        Turn Chaos Monkey scrip On/Off (0)." 1>&2
        echo -e "  -k        Kill probability for Chaos Monkey 0(0%)/10(10%)/2(50%) (0)." 1>&2
        echo -e "  -e        Which entity is killed by Chaos Monkey 0/1/2/3 (0)." 1>&2
        echo -e "  -f        Which ext file to read and process ($FILE)." 1>&2
        exit 1
    ;;
    : )
        echo -e "Invalid option: $OPTARG requires an argument" 1>&2
        echo -e "" 1>&2
        echo -e "Usage: execute [OPTIONS] -f <FILE>" 1>&2
        echo -e "Runs the Map/Reduce project from CD 2019" 1>&2
        echo -e "  -h        Display this help message." 1>&2
        echo -e "  -c        Define the number of Cordinators (1)." 1>&2
        echo -e "  -w        Define the number of Workers (1)." 1>&2
        echo -e "  -m        Turn Chaos Monkey scrip On/Off (0)." 1>&2
        echo -e "  -k        Kill probability for Chaos Monkey 0(0%)/10(10%)/2(50%) (0)." 1>&2
        echo -e "  -e        Which entity is killed by Chaos Monkey 0/1/2/3 (0)." 1>&2
        echo -e "  -f        Which ext file to read and process ($FILE)." 1>&2
        exit 1
    ;;
    esac
done
shift $((OPTIND -1))

echo -e "Coordinators $COORDINATORS Workers $WORKERS"
echo -e "Monkey $MONKEY Kill Probability $KILL_PROBABILITY Entity $ENTITY"
echo -e "File: $FILE"

START=$(date +%s.%N)
echo -e "Start $COORDINATORS Coordinators:"
declare -a C_PIDS
for ((i = 0 ; i < $COORDINATORS ; i++ )); do
    ./loop.sh coordinator -f $FILE > /dev/null 2>&1 &
    C_PIDS[$i]=$!
done

sleep 5

echo -e "Start $WORKERS workers:"
for ((i = 0 ; i < $WORKERS ; i++ )); do
    ./loop.sh worker > /dev/null 2>&1 &
done

if [[ $MONKEY -eq 1 ]]; then
  echo -e "Start Chaos Monkey"
  ./chaos_monkey.sh $KILL_PROBABILITY $ENTITY > /dev/null 2>&1 &
  M_PID=$!
fi

echo -e "Wait for the Coordinators to end..."
for ((i = 0 ; i < $COORDINATORS ; i++ )); do
  wait ${C_PIDS[$i]}
done

echo -e "Kill all the workers, coordinators and loops"
workers=$(pgrep -f worker.py | xargs)
coordenators=$(pgrep -f coordinator.py | xargs)
loops=$(pgrep -f loop.sh | xargs)
procs="$loops $workers $coordenators"
for pid in $procs; do
    kill  $pid
done
kill $(lsof -t -i:8765)

if [[ $MONKEY -eq 1 ]]; then
    echo -e "Kill the chaos monkey"
    kill ${M_PID}
fi

END=$(date +%s.%N)
DIFF=$(echo "$END - $START" | bc -l)
echo -e "Average time: $DIFF"

echo -e "Check similarity score:"
RES=$(basename $FILE .txt)
python3 test.py -o output.csv -r "$RES.csv"
