name=RES-STABILITY
conf=resource-stability.json
globals=(STABLE_AGE)
function genconf {
	cat <<-EOF >"$1"
	{
		"StableAge": ${STABLE_AGE:-60}
	}
	EOF
}
