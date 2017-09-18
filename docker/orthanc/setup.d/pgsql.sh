name=PG
plugins=(libOrthancPostgreSQLIndex libOrthancPostgreSQLStorage)
conf=postgresql
settings=(INDEX STORAGE HOST PORT DB USER PASSWORD LOCK)
secrets=(PASSWORD)
function genconf {
	cat <<-EOF >$1
	{
		"PostgreSQL": {
			"EnableIndex": ${INDEX:-false},
			"EnableStorage": ${STORAGE:-false},
			"Host": "$HOST",
			"Port": ${PORT:-5432},
			"Database": "${DB:-postgres}",
			"Username": "${USER:-postgres}",
			"Password": "$PASSWORD",
			"Lock": ${LOCK:-false}
		}
	}
	EOF
}
