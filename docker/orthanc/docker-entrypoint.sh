#!/usr/bin/env bash
set -o errexit

if [[ $# -ne 1 ]]; then
	echo "FATAL ERROR: docker-entrypoint.sh expects a single parameter: the path to the configuration files(s)"
	exit 2
fi


# DCMTK calls gethostid() when generating DICOM UIDs (used, e.g, in modifications/anonymizations).
# When /etc/hostid is missing, the system tries to generate it from the IP of the system.
# On some system, in particular circumstances, we have observed that the system performs a DNS query
# to get the IP of the system.  This DNS can timeout (after multiple with retries) and, in particular cases,
# we have observed a delay of 40 seconds to generate a single DICOM UID in Orthanc.
# Therefore, if /etc/hostid is missing, we generate it with a random number.  This behaviour can still be deactivated by 
# defining GENERATE_HOST_ID_IF_MISSING=false.  The host id can also be forced by defining FORCE_HOST_ID
if [[ ! -z $FORCE_HOST_ID ]];then
	echo "Forcing hostid in /etc/hostid: $FORCE_HOST_ID"
	echo $FORCE_HOST_ID > /etc/hostid
elif [[ ! $GENERATE_HOST_ID_IF_MISSING || $GENERATE_HOST_ID_IF_MISSING == true ]]; then
	if [[ ! -f /etc/hostid || $(< /etc/hostid) = 'not-generated' ]]; then
		host_id=$(printf '%x' $(shuf -i 268435456-4294967295 -n 1))
		echo "Generating random hostid in /etc/hostid: $host_id"
		echo $host_id > /etc/hostid
	fi
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
echo "Startup command: exec \"${argv[*]}\"" >&2
exec "${argv[@]}"
