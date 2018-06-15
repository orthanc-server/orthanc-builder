name=LISTENER
conf=listener
settings=(LISTEN_ALL_ADDR)
deprecated=(LISTEN_ALL_ADDR)
function genconf {
	cat <<-EOF >"$1"
	{
		"RemoteAccessAllowed": ${LISTEN_ALL_ADDR:-true}
	}
	EOF
}
