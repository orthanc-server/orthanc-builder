name=WVB
conf=osimis-webviewer
settings=(STUDY_DOWNLOAD_ENABLED VIDEO_ENABLED ANNOTATIONS_STORAGE_ENABLED KEY_IMAGE_CAPTURE_ENABLED)
plugin=libOsimisWebViewer
function genconf {
	cat <<-EOF >"$1"
	{
		"WebViewer": {
			"StudyDownloadEnabled": ${STUDY_DOWNLOAD_ENABLED:-true},
			"VideoDisplayEnabled": ${VIDEO_ENABLED:-true},
			"AnnotationStorageEnabled": ${ANNOTATIONS_STORAGE_ENABLED:-false},
			"KeyImageCaptureEnabled": ${KEY_IMAGE_CAPTURE_ENABLED:-false}
		}
	}
	EOF
}
