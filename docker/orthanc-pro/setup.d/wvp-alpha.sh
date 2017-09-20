# WARNING: conflicts with WVP (stable)
name=WVP_ALPHA
conf=osimis-webviewer-alpha
settings=(STUDY_DOWNLOAD VIDEO ANNOTATIONS_STORAGE LIVESHARE LICENSE_STRING)
secrets=(LICENSE_STRING)
plugin=libOsimisWebViewerProAlpha
function genconf {
	cat <<-EOF >"$1"
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
