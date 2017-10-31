name=HTTP
conf=http
settings=(CL_TIMEOUT CL_VERIFY_PEERS PORT)
function genconf {
	cat <<-EOF >"$1"
	{
		"HttpTimeout": ${CL_TIMEOUT:-0},
		"HttpsVerifyPeers": ${CL_VERIFY_PEERS:-true},
		"HttpPort": ${PORT:-8042}
	}
	EOF
}
