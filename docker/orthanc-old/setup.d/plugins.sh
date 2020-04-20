name=PLUGINS
conf=plugins
settings=(DIR)
default=true
function genconf {
	cat <<-EOF >"$1"
	{
		"Plugins": ["${DIR:-/usr/share/orthanc/plugins}"]
	}
	EOF
}
