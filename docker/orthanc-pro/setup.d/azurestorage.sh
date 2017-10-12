name=AZSTOR
conf=azure-storage
settings=(ACC_NAME ACC_KEY CONTAINER LICENSE_STRING)
secrets=(ACC_KEY LICENSE_STRING)
plugin=libOrthancBlobStorage
function genconf {
	if [[ ! $ACC_NAME ]]; then
		log "Missing ACC_NAME setting, not generating configuration file"
		return 1
	fi
	if [[ ! $ACC_KEY ]]; then
		log "Missing ACC_KEY setting, not generating configuration file"
		return 2
	fi
	if [[ ! $LICENSE_STRING ]]; then
		log "Missing LICENSE_STRING setting, not generating configuration file"
		return 3
	fi
	if [[ ! $CONTAINER ]]; then
		log "Missing CONTAINER setting, not generating configuration file"
		return 4
	fi
	cat <<-EOF >"$1"
	{
		"BlobStorage": {
			"Enable": true,
			"AccountName": "$ACC_NAME",
			"AccountKey": "$ACC_KEY",
			"LicenseString": "$LICENSE_STRING",
			"ContainerName": "$CONTAINER"
		}
	}
	EOF
}
