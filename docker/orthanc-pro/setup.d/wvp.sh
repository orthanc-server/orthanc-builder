name=WVP
conf=osimis-webviewer
settings=(STUDY_DOWNLOAD_ENABLED VIDEO ANNOTATIONS_STORAGE LIVESHARE LICENSE_STRING)
secrets=(LICENSE_STRING)
plugin=libOsimisWebViewerPro
function genconf {
	cat <<-EOF >"$1"
	{
		"WebViewer": {
			"StudyDownloadEnabled": ${STUDY_DOWNLOAD_ENABLED:-true},
			"VideoDisplayEnabled": ${VIDEO_ENABLED:-true},
			"AnnotationStorageEnabled": ${ANNOTATIONS_STORAGE_ENABLED:-false},
			"LiveshareEnabled": ${LIVESHARE_ENABLED:-false},
			"LicenseString": "$LICENSE_STRING"
		}
	}
	EOF
}
