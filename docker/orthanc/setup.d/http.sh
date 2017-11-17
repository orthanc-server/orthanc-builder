name=HTTP
conf=http
settings=(CL_TIMEOUT CL_VERIFY_PEERS CL_PROXY PORT)
function genconf {
	cat <<-EOF >"$1"
	{
		"HttpTimeout": ${CL_TIMEOUT:-0},
		"HttpsVerifyPeers": ${CL_VERIFY_PEERS:-true},
		"HttpProxy": "$CL_PROXY",
		"HttpPort": ${PORT:-8042}
	}
	EOF
}
