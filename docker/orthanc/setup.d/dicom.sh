name=DICOM
conf=dicom
settings=(AET MODALITIES AET_CHECK_ENABLED)
function genconf {
	cat <<-EOF >"$1"
	{
		"DicomAet": "${AET:-ORTHANC}",
		"DicomModalities": ${MODALITIES:-{}},
		"DicomCheckCalledAet": ${AET_CHECK_ENABLED:-false}
	}
	EOF
}
