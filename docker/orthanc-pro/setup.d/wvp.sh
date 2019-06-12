name=WVP
conf=osimis-webviewer-pro
settings=(
	STUDY_DOWNLOAD_ENABLED
	VIDEO_ENABLED
	ANNOTATIONS_STORAGE_ENABLED
	LIVESHARE_ENABLED
	LICENSE_STRING
	KEY_IMAGE_CAPTURE_ENABLED
	KEYBOARD_SHORTCUTS_ENABLED
	COMBINED_TOOL_ENABLED
	DEFAULT_SELECTED_TOOL
	LANGUAGE
	TOGGLE_OVERLAY_TEXT_BUTTON_ENABLED
	OPEN_ALL_PATIENT_STUDIES
	SERIES_TO_IGNORE
	DOWNLOAD_AS_JPEG_ENABLED
)
secrets=(LICENSE_STRING)
plugin=libOsimisWebViewerPro

if [[ $WVP_ALPHA_ENABLED == true ]]; then
	plugin=libOsimisWebViewerProAlpha
	WVP_ENABLED=true
fi

function genconf {
	if [[ ! $LICENSE_STRING ]]; then
		log "Missing LICENSE_STRING setting, not generating configuration file"
		return 1
	fi
	cat <<-EOF >"$1"
	{
		"WebViewer": {
			"LiveshareEnabled": ${LIVESHARE_ENABLED:-false},
			"LicenseString": "$LICENSE_STRING",

			"StudyDownloadEnabled": ${STUDY_DOWNLOAD_ENABLED:-true},
			"DownloadAsJpegEnabled": ${DOWNLOAD_AS_JPEG_ENABLED:-false},
			"VideoDisplayEnabled": ${VIDEO_ENABLED:-true},
			"AnnotationStorageEnabled": ${ANNOTATIONS_STORAGE_ENABLED:-false},
			"KeyImageCaptureEnabled": ${KEY_IMAGE_CAPTURE_ENABLED:-false},
			"KeyboardShortcutsEnabled": ${KEYBOARD_SHORTCUTS_ENABLED:-true},
			"CombinedToolEnabled": ${COMBINED_TOOL_ENABLED:-false},
			"DefaultSelectedTool": "${DEFAULT_SELECTED_TOOL:-zoom}",
			"DefaultLanguage": "${LANGUAGE:-en}",
			"ToggleOverlayTextButtonEnabled": ${TOGGLE_OVERLAY_TEXT_BUTTON_ENABLED:-false},
			"OpenAllPatientStudies": ${OPEN_ALL_PATIENT_STUDIES:-true},
			"SeriesToIgnore": ${SERIES_TO_IGNORE:-"{}"}
		}
	}
	EOF
}
