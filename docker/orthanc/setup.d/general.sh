name=GENERAL
conf=orthanc
function genconf {
	cat <<-EOF >"$1"
	{
		"Name": "${NAME:-ORTHANC}"
	}
	EOF
}
