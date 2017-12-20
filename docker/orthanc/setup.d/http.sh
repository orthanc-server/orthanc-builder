name=HTTP
conf=http
settings=(CL_TIMEOUT CL_VERIFY_PEERS CL_CA_CERTS CL_PROXY PORT)
default=true
function genconf {
	cat <<-EOF >"$1"
	{
		"HttpTimeout": ${CL_TIMEOUT:-0},
		"HttpsVerifyPeers": ${CL_VERIFY_PEERS:-true},
		"HttpsCACertificates" : "${CL_CA_CERTS:-/etc/ssl/certs/ca-certificates.crt},"
		"HttpProxy": "$CL_PROXY",
		"HttpPort": ${PORT:-8042}
	}
	EOF
}
