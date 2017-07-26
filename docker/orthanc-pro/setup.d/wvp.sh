#!/usr/bin/env bash
set -o errexit
licenseStringFile=/run/secrets/${WVP_LICENSE_STRING_SECRET:-wvp-licensestring}

if [[ ! -e "$licenseStringFile" ]]; then
	echo "WVP-SETUP: Use wvp-licensestring Docker secret to enable" >&2
	echo "WVP-SETUP: Fallback to Osimis Web Viewer Basic" >&2
	exit 0
fi

echo "WVP-SETUP: Found license, writing wvp.json, disabling WVB, enabling WVP" >&2
licenseString=$(<"$licenseStringFile")
cat <<EOF >/etc/orthanc/osimis-webviewer.json
{
	"WebViewer": {
		"StudyDownloadEnabled": true,
		"VideoDisplayEnabled": true,
		"AnnotationStorageEnabled": false,
		"LiveshareEnabled": false,
		"LicenseString": "$licenseString"
	}
}
EOF
mv /usr/share/orthanc/plugins{,-disabled}/libOsimisWebViewer.so
mv /usr/share/orthanc/plugins{-disabled,}/libOsimisWebViewerPro.so
