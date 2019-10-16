name=AC
conf=remote-access
settings=(
	ALLOW_REMOTE 
  AUTHENTICATION_ENABLED
	REGISTERED_USERS
)
default=true
function genconf {
	cat <<-EOF >"$1"
	{
    "RemoteAccessAllowed": ${ALLOW_REMOTE:-true},
    "AuthenticationEnabled": ${AUTHENTICATION_ENABLED:-true},
    "RegisteredUsers": ${REGISTERED_USERS:-"{}"}
	}
	EOF
}
