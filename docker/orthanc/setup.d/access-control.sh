name=AC
conf=remote-access
settings=(
	ALLOW_REMOTE 
  AUTHENTICATION_ENABLED
	REGISTERED_USERS
)
default=true
if [ -z "$AC_REGISTERED_USERS" ]; then
	defaultPassword=$(dd if=/dev/urandom bs=1 count=32 2>/dev/null | base64 -w 0 | rev | cut -b 2- | rev)
	defaultRegisteredUsers=""{\"orthanc\":\"$defaultPassword\"}""
  if [ -z "$AC_AUTHENTICATION_ENABLED" ] || [  "$AC_AUTHENTICATION_ENABLED" == "true" ]; then
	  echo "Since you've not defined any AC_REGISTERED_USERS, we've defined one for you: orthanc:$defaultPassword"
  fi
fi
function genconf {
	cat <<-EOF >"$1"
	{
    "RemoteAccessAllowed": ${ALLOW_REMOTE:-true},
    "AuthenticationEnabled": ${AUTHENTICATION_ENABLED:-true},
    "RegisteredUsers": ${REGISTERED_USERS:-"$defaultRegisteredUsers"}
	}
	EOF
}
