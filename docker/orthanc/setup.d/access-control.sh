name=AC
conf=remote-access
settings=(ALLOW_REMOTE)
default=true
function genconf {
	cat <<-EOF >"$1"
	{
		"RemoteAccessAllowed": ${ALLOW_REMOTE:-true}
	}
	EOF
}
