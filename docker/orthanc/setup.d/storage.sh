name=STORAGE
conf=storage
settings=(DIR MAX_SIZE MAX_PATIENTS)
globals=(STORE_DICOM)
default=true
function genconf {
	cat <<-EOF >"$1"
	{
		"StorageDirectory": "${DIR:-/var/lib/orthanc/db}",
		"MaximumStorageSize": ${MAX_SIZE:-0},
		"MaximumPatientCount": ${MAX_PATIENTS:-0},
		"StoreDicom": ${STORE_DICOM:-true}
	}
	EOF
}
