name=SCHED
conf=scheduler
settings=(MAX_JOBS MAX_QUEUED_JOBS SAVE_JOBS)
function genconf {
	# MAX_JOBS is deprecated
	MAX_QUEUED_JOBS=${MAX_QUEUED_JOBS:-$MAX_JOBS}

	cat <<-EOF >"$1"
	{
		"LimitJobs": ${MAX_QUEUED_JOBS:-10},
		"SaveJobs": ${SAVE_JOBS:-true}
	}
	EOF
}
