name=PG
plugins=(libOrthancPostgreSQLIndex libOrthancPostgreSQLStorage)
conf=postgresql
settings=(INDEX STORAGE HOST PORT DB USER PASSWORD LOCK)
secret PASSWORD
function genconf {
	cat <<-EOF >$1
	{
		"PostgreSQL": {
			"EnableIndex": ${PG_INDEX:-false},
			"EnableStorage": ${PG_STORAGE:-false},
			"Host": "$PG_HOST",
			"Port": ${PG_PORT:-5432},
			"Database": "${PG_DB:-postgres}",
			"Username": "${PG_USER:-postgres}",
			"Password": "$PG_PASSWORD",
			"Lock": ${PG_LOCK:-false}
		}
	}
	EOF
}
