name=WVB
conf=osimis-webviewer
settings=(STUDY_DOWNLOAD VIDEO ANNOTATIONS_STORAGE)
plugin=libOsimisWebViewer
function genconf {
	cat <<-EOF >"$1"
	{
		"WebViewer": {
			"StudyDownloadEnabled": ${STUDY_DOWNLOAD:-true},
			"VideoDisplayEnabled": ${VIDEO:-true},
			"AnnotationStorageEnabled": ${ANNOTATIONS_STORAGE:-false}
		}
	}
	EOF
}
