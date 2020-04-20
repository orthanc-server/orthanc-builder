name=MSSQL
conf=mssql
settings=(CONNECTION_STRING LICENSE_STRING LOCK MAXIMUM_CONNECTION_RETRIES CONNECTION_RETRY_INTERVAL)
secrets=(CONNECTION_STRING LICENSE_STRING)
plugin=libOrthancMsSqlIndex
function genconf {
	if [[ ! $CONNECTION_STRING ]]; then
		err "Missing CONNECTION_STRING setting"
		return 1
	fi
	if [[ ! $LICENSE_STRING ]]; then
		err "Missing LICENSE_STRING setting"
		return 2
	fi
	cat <<-EOF >"$1"
	{
		"MSSQL" : {
			"EnableIndex": true,
			"EnableStorage": false,
			"ConnectionString": "$CONNECTION_STRING",
			"LicenseString": "$LICENSE_STRING",
			"Lock": ${LOCK:-false},
			"MaximumConnectionRetries": ${MAXIMUM_CONNECTION_RETRIES:-10},
			"ConnectionRetryInterval": ${CONNECTION_RETRY_INTERVAL:-5}
		}
	}
	EOF
}
