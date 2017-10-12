name=MSSQL
conf=mssql
settings=(CONNECTION_STRING LICENSE_STRING LOCK)
secrets=(CONNECTION_STRING LICENSE_STRING)
plugin=libOrthancMsSqlIndex
function genconf {
	if [[ ! $CONNECTION_STRING ]]; then
		log "Missing CONNECTION_STRING setting, not generating configuration file"
		return 1
	fi
	if [[ ! $LICENSE_STRING ]]; then
		log "Missing LICENSE_STRING setting, not generating configuration file"
		return 2
	fi
	cat <<-EOF >"$1"
	{
		"MSSQL" : {
			"EnableIndex": true,
			"EnableStorage": false,
			"ConnectionString": "$CONNECTION_STRING",
			"LicenseString": "$LICENSE_STRING",
			"Lock": ${LOCK:-false}
		}
	}
	EOF
}
