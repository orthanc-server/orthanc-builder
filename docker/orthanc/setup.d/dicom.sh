name=DICOM
conf=dicom
settings=(AET MODALITIES)
default=true
function genconf {
	# TODO use more descriptive settings names
	cat <<-EOF >"$1"
	{
		"DicomAet": "${AET:-ORTHANC}",
		"DicomModalities" : ${MODALITIES:-{}}
	}
	EOF
}
