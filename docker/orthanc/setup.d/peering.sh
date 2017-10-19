name=PEERING
conf=peering
globals=(PEERS)
function genconf {
	cat <<-EOF >"$1"
	{
		"OrthancPeers": ${PEERS:-{}}
	}
	EOF
}
