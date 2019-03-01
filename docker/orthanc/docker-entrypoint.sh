#!/usr/bin/env bash
set -o errexit
base=/usr/lib/orthanc

# call setup.sh on each setup procedure script found in $base/setup.d (one for each plugin).
find "$base/setup.d" -type f -exec "$base/setup.sh" "{}" ";"

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
