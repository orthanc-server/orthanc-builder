name=DICOM
conf=dicom
settings=(
	AET
	MODALITIES
	PORT
	SCP_TIMEOUT
	SCU_TIMEOUT
	AET_CHECK_ENABLED
	SRC_CHECK_ENABLED
	CS_AET_MATCH_ENABLED
	STORE_UKN_SCU_ENABLED
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
		"DicomCheckModalityHost": ${SRC_CHECK_ENABLED:-false},
		"StrictAetComparison": ${CS_AET_MATCH_ENABLED:-false},
		"DicomAlwaysAllowStore": ${STORE_UKN_SCU_ENABLED:-true}
	}
	EOF
}
