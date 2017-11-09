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
	DICOM_ALWAYS_ALLOW_ECHO_ENABLED
	DICOM_ALWAYS_ALLOW_STORE_ENABLED
)
function genconf {
	cat <<-EOF >"$1"
	{
		"DicomAet": "${AET:-ORTHANC}",
		"DicomModalities": ${MODALITIES:-{}},
		"DicomPort": ${PORT:-4242},
		"DicomScpTimeout": ${SCP_TIMEOUT:-30},
		"DicomScuTimeout": ${SCU_TIMEOUT:-10},
		"DicomCheckCalledAet": ${AET_CHECK_ENABLED:-false},
		"DicomCheckModalityHost": ${CHECK_MODALITY_HOST_ENABLED:-false},
		"StrictAetComparison": ${STRICT_AET_COMPARISON_ENABLED:-false},
		"DicomAlwaysAllowEcho": ${DICOM_ALWAYS_ALLOW_ECHO_ENABLED:-true}
		"DicomAlwaysAllowStore": ${DICOM_ALWAYS_ALLOW_STORE_ENABLED:-true}
	}
	EOF
}
