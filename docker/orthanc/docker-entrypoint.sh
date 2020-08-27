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

jobs=""
if [[ $NO_JOBS == true ]]; then
	jobs=--no-jobs
fi

unlock=""
if [[ $UNLOCK == true ]]; then
	unlock=--unlock
fi

argv=(Orthanc $verbosity $jobs $unlock "$@")
echo "Startup command: ${argv[*]}" >&2
exec "${argv[@]}"
