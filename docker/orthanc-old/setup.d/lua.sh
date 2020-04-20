name=LUA
conf=lua
settings=(SCRIPTS OPTIONS)
default=false
function genconf {
	cat <<-EOF >"$1"
	{
		"LuaScripts": ${SCRIPTS:-"[]"},
		"LuaOptions" : ${OPTIONS:-"{}"}
	}
	EOF
}
