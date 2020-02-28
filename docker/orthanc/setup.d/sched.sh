name=SCHED
conf=scheduler
settings=(MAX_JOBS MAX_QUEUED_JOBS MAX_CONCURRENT_JOBS SAVE_JOBS)
function genconf {
	# MAX_JOBS is deprecated
	MAX_QUEUED_JOBS=${MAX_QUEUED_JOBS:-$MAX_JOBS}

	cat <<-EOF >"$1"
	{
		"LimitJobs": ${MAX_QUEUED_JOBS:-10},
		"ConcurrentJobs": ${MAX_CONCURRENT_JOBS:-2},
		"SaveJobs": ${SAVE_JOBS:-true}
	}
	EOF
}
