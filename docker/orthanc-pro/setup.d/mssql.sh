#!/usr/bin/env bash
set -o errexit
licenseStringFile=/run/secrets/${MSSQL_LICENSE_STRING_SECRET:-mssql-licensestring}
connectionStringFile=/run/secrets/${MSSQL_CONNECTION_STRING_SECRET:-mssql-connectionstring}

if [[ ! -e "$licenseStringFile" || ! -e "$connectionStringFile" ]]; then
	echo "MSSQL-SETUP: Use mssql-licensestring and mssql-connectionstring Docker secrets to enable" >&2
	exit 0
fi

echo "MSSQL-SETUP: Found license and strings files, writing mssql.json" >&2
licensestring=$(<"$licenseStringFile")
connectionstring=$(<"$connectionStringFile")
cat <<EOF >/etc/orthanc/mssql.json
{
	"MSSQL" : {
		"EnableIndex": true,
		"EnableStorage": false,
		"ConnectionString": "$connectionstring",
		"LicenseString": "$licensestring"
	}
}
EOF
