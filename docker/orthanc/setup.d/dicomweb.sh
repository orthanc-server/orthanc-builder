name=DW
conf=dicomweb
settings=(ROOT WADO_URI_ENABLED WADO_URI_ROOT HOST TLS)
plugin=libOrthancDicomWeb
function genconf {
	# TODO use more descriptive settings names
	cat <<-EOF >"$1"
	{
		"DicomWeb": {
			"Enable": true,
			"Root": "${ROOT:-/dicom-web/}",
			"EnableWado": ${WADO_URI_ENABLED:-true},
			"WadoRoot": "${WADO_URI_ROOT:-/wado}",
			"Host": "${HOST:-localhost}",
			"Ssl": ${TLS:-false}
		}
	}
	EOF
}
