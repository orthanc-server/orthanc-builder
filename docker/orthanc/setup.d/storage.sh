name=STORAGE
conf=storage
settings=(DIR MAX_SIZE MAX_PATIENTS INDEX_ONLY)
default=true
function genconf {
	local store=true
	[[ $INDEX_ONLY == true ]] && store=false
	cat <<-EOF >"$1"
	{
		"StorageDirectory": "${DIR:-/var/lib/orthanc/db}",
		"MaximumStorageSize": ${MAX_SIZE:-0},
		"MaximumPatientCount": ${MAX_PATIENTS:-0},
		"StoreDicom": $store
	}
	EOF
}
