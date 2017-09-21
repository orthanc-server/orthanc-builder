name=WL
conf=worklists
settings=(STORAGE_DIR)
function genconf {
	cat <<-EOF >"$1"
	{
		"Worklists": {
			"Enable": true,
			"Database": "${STORAGE_DIR:-/var/lib/orthanc/worklists}"
		}
	}
	EOF
}
