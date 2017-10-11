name=MSSQL
conf=mssql
settings=(CONNECTION_STRING LICENSE_STRING)
secrets=(CONNECTION_STRING LICENSE_STRING LOCK)
plugin=libOrthancMsSqlIndex
function genconf {
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