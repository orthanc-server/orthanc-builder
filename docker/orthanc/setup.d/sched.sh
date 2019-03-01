name=SCHED
conf=scheduler
settings=(MAX_JOBS SAVE_JOBS)
function genconf {
	cat <<-EOF >"$1"
	{
		"LimitJobs": ${MAX_JOBS:-10},
		"SaveJobs": ${SAVE_JOBS:-true}
	}
	EOF
}
