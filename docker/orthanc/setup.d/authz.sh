name=AUTHZ
conf=authorization
settings=(
	WEBSERVICE
	TOKEN_HTTP_HEADERS
	TOKEN_GET_ARGUMENTS
	UNCHECKED_RESOURCES
	UNCHECKED_FOLDERS
	UNCHECKED_LEVELS
)
plugin=libOrthancAuthorization
function genconf {
	if [[ ! $WEBSERVICE ]]; then
		log "Missing WEBSERVICE setting, not generating configuration file"
		return 1
	fi
	cat <<-EOF >"$1"
	{
		"Authorization": {
			"WebService": "$WEBSERVICE",
			"TokenHttpHeaders": ${TOKEN_HTTP_HEADERS:-"[]"},
			"TokenGetArguments": ${TOKEN_GET_ARGUMENTS:-"[]"},
			"UncheckedResources": ${UNCHECKED_RESOURCES:-"[]"},
			"UncheckedFolders": ${UNCHECKED_FOLDERS:-"[]"},
			"UncheckedLevels": ${UNCHECKED_LEVELS:-"[]"}
		}
	}
	EOF
}
