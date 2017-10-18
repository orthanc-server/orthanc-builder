name=PEERING
conf=peering
settings=(PEERS)
function genconf {
	cat <<-EOF >"$1"
	{
		"OrthancPeers": ${PEERS:-{}}
	}
	EOF
}
