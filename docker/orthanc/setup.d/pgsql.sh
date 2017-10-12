name=PG
conf=postgresql
settings=(INDEX_ENABLED STORAGE_ENABLED HOST PORT DB USER PASSWORD LOCK)
secrets=(PASSWORD)
plugins=(libOrthancPostgreSQLIndex libOrthancPostgreSQLStorage)
function genconf {
	if [[ ! $HOST ]]; then
		log "Missing HOST setting, not generating configuration file"
		return 1
	fi
	if [[ $PASSWORD ]]; then
		passwordprop="\"Password\": \"$PASSWORD\","
	fi

	# We need the actual value we eventually pick for the plugin
	# selection below.  The `:=` syntax doesn't seem to have an
	# effect when performed within a heredoc (subprocess?) so we
	# perform the default value logic outside.
	if [[ ! $INDEX_ENABLED ]]; then
		INDEX_ENABLED=true
	fi
	if [[ ! $STORAGE_ENABLED ]]; then
		STORAGE_ENABLED=false
	fi

	cat <<-EOF >"$1"
	{
		"PostgreSQL": {
			"EnableIndex": $INDEX_ENABLED,
			"EnableStorage": $STORAGE_ENABLED,
			"Host": "$HOST",
			"Port": ${PORT:-5432},
			"Database": "${DB:-postgres}",
			"Username": "${USER:-postgres}",
			$passwordprop
			"Lock": ${LOCK:-false}
		}
	}
	EOF

	# PG_ENABLED alone will enable both plugins without generating a
	# configuration file, then let the user configure which to
	# enable using their own configuration files.  However, when we
	# *are* generating the configuration file, we *know* which will
	# be used and so we only enable them when necessary.
	plugins=()
	if [[ $INDEX_ENABLED == true ]]; then
		plugins+=(libOrthancPostgreSQLIndex)
	fi
	if [[ $STORAGE_ENABLED == true ]]; then
		plugins+=(libOrthancPostgreSQLStorage)
	fi
}
