name=LISTENER
conf=remote-access
settings=(LISTEN_ALL_ADDR)
default=true
function genconf {
	cat <<-EOF >"$1"
	{
		"RemoteAccessAllowed": ${LISTEN_ALL_ADDR:-true}
	}
	EOF
}
