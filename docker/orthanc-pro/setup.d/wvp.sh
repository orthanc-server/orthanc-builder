#!/usr/bin/env bash
set -o errexit

if [[ $WVP_LICENSE_STRING ]]; then
	licenseString=$WVP_LICENSE_STRING
else
	licenseStringFile=/run/secrets/${WVP_LICENSE_STRING_SECRET:-wvp-licensestring}

	if [[ ! -e "$licenseStringFile" ]]; then
		echo "WVP-SETUP: Use wvp-licensestring Docker secret to enable" >&2
		echo "WVP-SETUP: Fallback to Osimis Web Viewer Basic" >&2
		exit 0
	fi

	licenseString=$(<"$licenseStringFile")
fi

echo "WVP-SETUP: Found license, overwriting osimis-webviewer.json, disabling WVB, enabling WVP" >&2
cat <<EOF >/etc/orthanc/osimis-webviewer.json
{
	"WebViewer": {
		"StudyDownloadEnabled": ${WVP_STUDY_DOWNLOAD:-true},
		"VideoDisplayEnabled": ${WVP_VIDEO:-true},
		"AnnotationStorageEnabled": ${WVP_ANNOTATIONS_STORAGE:-false},
		"LiveshareEnabled": ${WVP_LIVESHARE:-false},
		"LicenseString": "$licenseString"
	}
}
EOF
mv /usr/share/orthanc/plugins{,-disabled}/libOsimisWebViewer.so
mv /usr/share/orthanc/plugins{-disabled,}/libOsimisWebViewerPro.so
