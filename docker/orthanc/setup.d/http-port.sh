name=HTTP
conf=http-port
settings=(PORT)
function genconf {
	cat <<-EOF >$1
	{
		"HttpPort": ${PORT:-80}
	}
	EOF
}
