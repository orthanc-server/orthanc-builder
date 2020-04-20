name=LISTENER
conf=listener
settings=(LISTEN_ALL_ADDR)
deprecated=(LISTEN_ALL_ADDR)
function genconf {
	cat <<-EOF >"$1"
	{
		"RemoteAccessAllowed": ${LISTEN_ALL_ADDR:-true}
	}
	EOF
}

# Important note: This setup procedure is currently incompatible with the AC
# setup procedure which is enabled by default and virtually necessary for
# operating in a container not in host networking mode (almost all
# environments). This significantly reduces its usefulness. Even beyond this
# incompatibility, LISTEN_ALL_ADDR never actually worked and currently cannot
# be fixed without changes to Orthanc (see commit log for this setup procedure
# for details).
#
# In the future, it is likely that we will be prompted to either:
# - Remove the LISTEN_ALL_ADDR setting.
# - Remove the setup procedure altogether.
# - Fix the LISTEN_ALL_ADDR setting.
#
# Given the setting didn't work to begin with and given it is currently the
# only setting in the setup procedure, options 1 and 2 are reasonable (no
# breakage expected, side-effects are taken over by new default AC setup
# procedure). As explained previously, option 3 requires upstream patches.
