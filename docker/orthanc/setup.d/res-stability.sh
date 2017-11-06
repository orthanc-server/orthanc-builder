name=RES-STABILITY
conf=resource-stability
globals=(STABLE_AGE)
function genconf {
	cat <<-EOF >"$1"
	{
		"StableAge": ${STABLE_AGE:-60}
	}
	EOF
}
