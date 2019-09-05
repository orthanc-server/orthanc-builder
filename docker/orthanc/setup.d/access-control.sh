name=AC
conf=remote-access
settings=(
	ALLOW_REMOTE 
  AUTHENTICATION_ENABLED
)
default=true
function genconf {
	cat <<-EOF >"$1"
	{
		"RemoteAccessAllowed": ${ALLOW_REMOTE:-true},
		"AuthenticationEnabled": ${AUTHENTICATION_ENABLED:-false}
	}
	EOF
}
