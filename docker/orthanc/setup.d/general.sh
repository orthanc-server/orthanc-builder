name=GENERAL
conf=orthanc
globals=(
	NAME
	EXECUTE_LUA_ENABLED
)
function genconf {
	cat <<-EOF >"$1"
	{
		"Name": "${NAME:-ORTHANC}",
		"ExecuteLuaEnabled" : ${EXECUTE_LUA_ENABLED:-false}
	}
	EOF
}
