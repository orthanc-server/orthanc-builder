name=AZSTOR
conf=azure-storage
settings=(ACC_NAME ACC_KEY CONTAINER LICENSE_STRING)
secrets=(ACC_KEY LICENSE_STRING)
plugin=libOrthancBlobStorage
function genconf {
	if [[ ! $ACC_NAME ]]; then
		err "Missing ACC_NAME setting"
		return 1
	fi
	if [[ ! $ACC_KEY ]]; then
		err "Missing ACC_KEY setting"
		return 2
	fi
	if [[ ! $LICENSE_STRING ]]; then
		err "Missing LICENSE_STRING setting"
		return 3
	fi
	if [[ ! $CONTAINER ]]; then
		err "Missing CONTAINER setting"
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
