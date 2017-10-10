name=GENERAL
conf=orthanc
default=true
function genconf {
	cat <<-EOF >"$1"
	{
		"Name": "${NAME:-ORTHANC}"
	}
	EOF
}
