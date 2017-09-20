name=AZSTOR
conf=azure-storage
settings=(ACC_NAME ACC_KEY CONTAINER LICENSE_STRING)
secrets=(ACC_KEY LICENSE_STRING)
plugin=libOrthancBlobStorage
function genconf {
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
