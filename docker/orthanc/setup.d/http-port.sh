name=HTTP
conf=http-port
settings=(PORT)
function genconf {
	cat <<-EOF >$1
	{
		"HttpPort": ${HTTP_PORT:-80}
	}
	EOF
}
