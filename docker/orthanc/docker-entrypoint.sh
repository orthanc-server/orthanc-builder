#!/usr/bin/env bash
set -o errexit

if [[ $# -ne 1 ]]; then
	echo "FATAL ERROR: docker-entrypoint.sh expects a single parameter: the path to the configuration files(s)"
	exit 2
fi

# generate the configuration file
cd /startup
python3 generateConfiguration.py

if [[ $TRACE_ENABLED == true ]]; then
	verbosity=--trace
elif [[ $VERBOSE_ENABLED == true ]]; then
	verbosity=--verbose
fi

if [[ ! -z $LOGDIR ]];then
	logoption=--logdir=$LOGDIR
elif [[ ! -z $LOGFILE ]];then
	logoption=--logfile=$LOGFILE
fi

jobs=""
if [[ $NO_JOBS == true ]]; then
	jobs=--no-jobs
fi

if [[ ! -z $BEFORE_ORTHANC_STARTUP_SCRIPT ]]; then
	echo "running custom startup script"
	$BEFORE_ORTHANC_STARTUP_SCRIPT
fi

argv=(Orthanc $verbosity $logoption $jobs "$@")
echo "Startup command: ${argv[*]}" >&2
exec "${argv[@]}"
