#!/usr/bin/env bash

show_help() {
    cat << EOF
    Usage: ${0##*/} [-hv] [-f OUTFILE] [FILE]...
    Do stuff with FILE and write the result to standard output. With no FILE
    or when FILE is -, read standard input.

        -h          display this help and exit
        -f OUTFILE  write the result to OUTFILE instead of standard output.
        -v          verbose mode. Can be used multiple times for increased
                    verbosity.
    EOF
    }

COORDINATOR=${1:-1}
WORKERS=${2:-0}

OPTIND=1
while getopts hvf: opt; do
    case $opt in
    h)
    show_help
    exit 0
    ;;
    v)  verbose=$((verbose+1))
    ;;
    f)  output_file=$OPTARG
    ;;
    *)
    show_help >&2
    exit 1
    ;;
    esac
done
shift "$((OPTIND-1))"   # Discard the options and sentinel --