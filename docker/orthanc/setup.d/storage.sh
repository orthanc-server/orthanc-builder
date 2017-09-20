name=STORAGE
conf=storage
settings=(DIR)
default=true
function genconf {
	cat <<-EOF >"$1"
	{
		"StorageDirectory": "${DIR:-/var/lib/orthanc/db}"
	}
	EOF
}
