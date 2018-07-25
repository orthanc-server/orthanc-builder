name=WVB
conf=osimis-webviewer
settings=(
	STUDY_DOWNLOAD_ENABLED
	VIDEO_ENABLED
	ANNOTATIONS_STORAGE_ENABLED
	KEY_IMAGE_CAPTURE_ENABLED
	KEYBOARD_SHORTCUTS_ENABLED
	COMBINED_TOOL_ENABLED
	DEFAULT_SELECTED_TOOL
	LANGUAGE
	TOGGLE_OVERLAY_TEXT_BUTTON_ENABLED
	OPEN_ALL_PATIENT_STUDIES
)
plugin=libOsimisWebViewer

if [[ $WVB_ALPHA_ENABLED == true ]]; then
	plugin=libOsimisWebViewerAlpha
	WVB_ENABLED=true
fi

function genconf {
	cat <<-EOF >"$1"
	{
		"WebViewer": {
			"StudyDownloadEnabled": ${STUDY_DOWNLOAD_ENABLED:-true},
			"VideoDisplayEnabled": ${VIDEO_ENABLED:-true},
			"AnnotationStorageEnabled": ${ANNOTATIONS_STORAGE_ENABLED:-false},
			"KeyImageCaptureEnabled": ${KEY_IMAGE_CAPTURE_ENABLED:-false},
			"KeyboardShortcutsEnabled": ${KEYBOARD_SHORTCUTS_ENABLED:-true},
			"CombinedToolEnabled": ${COMBINED_TOOL_ENABLED:-false},
			"DefaultSelectedTool": "${DEFAULT_SELECTED_TOOL:-zoom}",
			"DefaultLanguage": "${LANGUAGE:-en}",
			"ToggleOverlayTextButtonEnabled": ${TOGGLE_OVERLAY_TEXT_BUTTON_ENABLED:-false},
			"OpenAllPatientStudies": ${OPEN_ALL_PATIENT_STUDIES:-true}
		}
	}
	EOF
}
