name=LUA
conf=lua
settings=(SCRIPTS)
default=false
function genconf {
	cat <<-EOF >"$1"
	{
		"LuaScripts": ${SCRIPTS:-"[]"}
	}
	EOF
}
