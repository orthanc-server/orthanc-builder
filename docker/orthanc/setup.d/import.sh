name=IMPORT
conf=import
settings=(OVERWRITE_INSTANCES)
function genconf {
	cat <<-EOF >"$1"
	{
		"OverwriteInstances": ${OVERWRITE_INSTANCES:-false}
	}
	EOF
}
