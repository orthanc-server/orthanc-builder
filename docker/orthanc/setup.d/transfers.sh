name=TRANSFERS
conf=transfers
settings=(THREADS RETRIES BUCKET_SIZE CACHE_SIZE MAX_PUSH_TRANSACTIONS)
plugin=libOrthancTransfers
function genconf {
    # TODO - Consider adding more options:
    # http://book.orthanc-server.com/plugins/transfers.html#advanced-options
	cat <<-EOF >"$1"
	{
		"Transfers": {
			"Threads" : ${THREADS:-6},
			"MaxHttpRetries" : ${RETRIES:-0},
			"BucketSize": ${BUCKET_SIZE:-4096},
			"CacheSize": ${CACHE_SIZE:-128},
			"MaxPushTransactions": ${MAX_PUSH_TRANSACTIONS:-4}
		}
	}
	EOF
}
