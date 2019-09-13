name=WVP
conf=osimis-webviewer-pro
settings=(
	LICENSE_STRING
	LIVESHARE_ENABLED
	ANNOTATIONS_STORAGE_ENABLED
	COMBINED_TOOL_ENABLED
	DEFAULT_SELECTED_TOOL
	DOWNLOAD_AS_JPEG_ENABLED
	KEY_IMAGE_CAPTURE_ENABLED
	KEYBOARD_SHORTCUTS_ENABLED
	LANGUAGE
	OPEN_ALL_PATIENT_STUDIES
	PRINT_ENABLED
	SERIES_TO_IGNORE
	STUDY_DOWNLOAD_ENABLED
	TOGGLE_OVERLAY_TEXT_BUTTON_ENABLED
	VIDEO_ENABLED
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
			"LicenseString": "$LICENSE_STRING",
			"LiveshareEnabled": ${LIVESHARE_ENABLED:-false},

			"AnnotationStorageEnabled": ${ANNOTATIONS_STORAGE_ENABLED:-false},
			"CombinedToolEnabled": ${COMBINED_TOOL_ENABLED:-false},
			"DefaultLanguage": "${LANGUAGE:-en}",
			"DefaultSelectedTool": "${DEFAULT_SELECTED_TOOL:-zoom}",
			"DownloadAsJpegEnabled": ${DOWNLOAD_AS_JPEG_ENABLED:-false},
			"KeyImageCaptureEnabled": ${KEY_IMAGE_CAPTURE_ENABLED:-false},
			"KeyboardShortcutsEnabled": ${KEYBOARD_SHORTCUTS_ENABLED:-true},
			"OpenAllPatientStudies": ${OPEN_ALL_PATIENT_STUDIES:-true},
			"PrintEnabled": ${PRINT_ENABLED:-true},
			"SeriesToIgnore": ${SERIES_TO_IGNORE:-"{}"},
			"StudyDownloadEnabled": ${STUDY_DOWNLOAD_ENABLED:-true},
			"ToggleOverlayTextButtonEnabled": ${TOGGLE_OVERLAY_TEXT_BUTTON_ENABLED:-false},
			"VideoDisplayEnabled": ${VIDEO_ENABLED:-true}
		}
	}
	EOF
}
