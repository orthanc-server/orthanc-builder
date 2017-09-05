#!/usr/bin/env bash
set -o errexit

if [[ $AZSTOR_LICENSE_STRING && $AZSTOR_ACC_NAME && $AZSTOR_ACC_KEY ]]; then
	licenseString=$AZSTOR_LICENSE_STRING
	accountName=$AZSTOR_ACC_NAME
	accountKey=$AZSTOR_ACC_KEY
else
	licenseStringFile=/run/secrets/${AZSTOR_LICENSE_STRING_SECRET:-azstor-licensestring}
	accountNameFile=/run/secrets/${AZSTOR_ACC_NAME_SECRET:-azstor-accname}
	accountKeyFile=/run/secrets/${AZSTOR_ACC_KEY_SECRET:-azstor-acckey}

	if [[ ! -e "$licenseStringFile" || ! -e "$accountNameFile" || ! -e "$accountKeyFile" ]]; then
		echo "AZSTOR-SETUP: Use azstor-licensestring, azstor-accname and azstor-acckey Docker secrets to enable" >&2
		exit 0
	fi

	licenseString=$(<"$licenseStringFile")
	accountName=$(<"$accountNameFile")
	accountKey=$(<"$accountKeyFile")
fi

containerName=${AZSTOR_CONTAINER:-orthanc}

echo "AZSTOR-SETUP: Found license, account name and key files, writing azure-storage.json and enabling Azure Storage plugin" >&2
cat <<EOF >/etc/orthanc/azure-storage.json
{
	"BlobStorage": {
		"Enable": true,
		"AccountName": "$accountName",
		"AccountKey": "$accountKey",
		"LicenseString": "$licenseString",
		"ContainerName": "$containerName"
	}
}
EOF
mv /usr/share/orthanc/plugins{-disabled,}/libOrthancBlobStorage.so
