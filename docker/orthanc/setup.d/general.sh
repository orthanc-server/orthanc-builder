name=GENERAL
conf=orthanc
globals=(NAME)
function genconf {
	cat <<-EOF >"$1"
	{
		"Name": "${NAME:-ORTHANC}"
	}
	EOF
}
