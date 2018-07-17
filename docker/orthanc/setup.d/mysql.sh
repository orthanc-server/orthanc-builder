name=MYSQL
conf=mysql
settings=(HOST PORT DB USER PASSWORD LOCK)
secrets=(PASSWORD)
plugins=(libOrthancMySQLIndex libOrthancMySQLStorage)
pluginselectors=(INDEX STORAGE:explicit)
function genconf {
	if [[ ! $HOST ]]; then
		log "Missing HOST setting, not generating configuration file"
		return 1
	fi
	if [[ $PASSWORD ]]; then
		passwordprop="\"Password\": \"$PASSWORD\","
	fi
	cat <<-EOF >"$1"
	{
		"MySQL": {
			"EnableIndex": ${INDEX_ENABLED:-true},
			"EnableStorage": ${STORAGE_ENABLED:-false},
			"Host": "$HOST",
			"Port": ${PORT:-3306},
			"Database": "${DB:-mysql}",
			"Username": "${USER:-root}",
			$passwordprop
			"Lock": ${LOCK:-false}
		}
	}
	EOF
}
