name=SCHED
conf=scheduler
settings=(MAX_JOBS)
function genconf {
	cat <<-EOF >"$1"
	{
		"LimitJobs": ${MAX_JOBS:-10}
	}
	EOF
}
