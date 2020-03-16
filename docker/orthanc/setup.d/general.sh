name=GENERAL
conf=orthanc
globals=(
	NAME
	EXECUTE_LUA_ENABLED
	STORAGE_ACCESS_ON_FIND
)
function genconf {
	cat <<-EOF >"$1"
	{
		"Name": "${NAME:-ORTHANC}",
		"ExecuteLuaEnabled" : ${EXECUTE_LUA_ENABLED:-false},
		"StorageAccessOnFind" : "${STORAGE_ACCESS_ON_FIND:-Always}"
	}
	EOF
}
