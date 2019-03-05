name=TRANSFERS
conf=transfers
settings=(THREADS RETRIES)
plugin=libOrthancTransfers
function genconf {
    # TODO - Consider adding more options:
    # http://book.orthanc-server.com/plugins/transfers.html#advanced-options
	cat <<-EOF >"$1"
	{
		"Transfers": {
			"Threads" : ${THREADS:-6},
			"MaxHttpRetries" : ${RETRIES:-0}
		}
	}
	EOF
}
