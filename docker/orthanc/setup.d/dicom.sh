name=DICOM
conf=dicom
settings=(AET MODALITIES)
function genconf {
	cat <<-EOF >"$1"
	{
		"DicomAet": "${AET:-ORTHANC}",
		"DicomModalities": ${MODALITIES:-{}}
	}
	EOF
}
