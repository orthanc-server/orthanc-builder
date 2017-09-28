name=GENERAL
conf=orthanc
settings=(NAME)
default=true
function genconf {
	# TODO use more descriptive settings names
	cat <<-EOF >"$1"
	{
		"Name": "${NAME:-ORTHANC}"
	}
	EOF
}
