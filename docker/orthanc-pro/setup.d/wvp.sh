name=WVP
conf=osimis-webviewer
settings=(STUDY_DOWNLOAD VIDEO ANNOTATIONS_STORAGE LIVESHARE LICENSE_STRING)
secrets=(LICENSE_STRING)
plugin=libOsimisWebViewerPro
function genconf {
	cat <<-EOF >/etc/orthanc/osimis-webviewer.json
	{
		"WebViewer": {
			"StudyDownloadEnabled": ${STUDY_DOWNLOAD:-true},
			"VideoDisplayEnabled": ${VIDEO:-true},
			"AnnotationStorageEnabled": ${ANNOTATIONS_STORAGE:-false},
			"LiveshareEnabled": ${LIVESHARE:-false},
			"LicenseString": "$LICENSE_STRING"
		}
	}
	EOF
}
