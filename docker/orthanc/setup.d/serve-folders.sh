name=SERVEFOLDERS
conf=serve-folders
settings=(ALLOW_CACHE GENERATE_ETAGS EXTENSIONS FOLDERS)
plugin=libServeFolders

function genconf {
	cat <<-EOF >"$1"
	{
		"ServeFolders": {
			"AllowCache": ${ALLOW_CACHE:-false},
			"GenerateETag": ${GENERATE_ETAGS:-true},
			"Extensions": ${EXTENSIONS:-{}},
			"Folders": ${FOLDERS:-{}}
		}
	}
	EOF
}
