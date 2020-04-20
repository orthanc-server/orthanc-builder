#!/usr/bin/env bash
set -o errexit

# generate the configuration file
cd /startup
python3.7 generateConfiguration.py

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
