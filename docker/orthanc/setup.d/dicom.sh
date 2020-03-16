name=DICOM
conf=dicom
settings=(
	AET
	MODALITIES
	PORT
	SCP_TIMEOUT
	SCU_TIMEOUT
	AET_CHECK_ENABLED
	CHECK_MODALITY_HOST_ENABLED
	STRICT_AET_COMPARISON_ENABLED
	ALWAYS_ALLOW_ECHO_ENABLED
	ALWAYS_ALLOW_STORE_ENABLED
	UNKNOWN_SOP_CLASS_ACCEPTED
	SYNCHRONOUS_CMOVE
	QUERY_RETRIEVE_SIZE
	DICTIONARY
)
function genconf {
	cat <<-EOF >"$1"
	{
		"DicomAet": "${AET:-ORTHANC}",
		"DicomModalities": ${MODALITIES:-"{}"},
		"DicomPort": ${PORT:-4242},
		"DicomScpTimeout": ${SCP_TIMEOUT:-30},
		"DicomScuTimeout": ${SCU_TIMEOUT:-10},
		"DicomCheckCalledAet": ${AET_CHECK_ENABLED:-false},
		"DicomCheckModalityHost": ${CHECK_MODALITY_HOST_ENABLED:-false},
		"StrictAetComparison": ${STRICT_AET_COMPARISON_ENABLED:-false},
		"DicomAlwaysAllowEcho": ${DICOM_ALWAYS_ALLOW_ECHO_ENABLED:-true},
		"DicomAlwaysAllowStore": ${DICOM_ALWAYS_ALLOW_STORE_ENABLED:-true},
		"UnknownSopClassAccepted": ${UNKNOWN_SOP_CLASS_ACCEPTED:-false},
		"SynchronousCMove": ${SYNCHRONOUS_CMOVE:-true},
		"QueryRetrieveSize": ${QUERY_RETRIEVE_SIZE:-10},
		"Dictionary": ${DICTIONARY:-"{}"}
	}
	EOF
}
