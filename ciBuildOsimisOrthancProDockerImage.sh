#!/usr/bin/env bash
set -o errexit
set -o xtrace

cd "${REPOSITORY_PATH:-$(git rev-parse --show-toplevel)}/docker"

# let's build the 'pro image'
mkdir --parents binaries/plugins-pro

# fetch mssql so file
mssqlPlugin=binaries/plugins-pro/libOrthancMsSqlIndex.so
if [[ ! -e $mssqlPlugin ]]; then
	# CHANGE_VERSION
	wget orthanc.osimis.io/docker-so/mssql/0.4.1/libOrthancMsSqlIndex.so \
		--output-document "$mssqlPlugin"
fi

function onExit {
	local -r numHandlers=${#exitHandlers[@]}
	for (( idx = numHandlers - 1; idx >= 0; idx-- )); do
		${exitHandlers[idx]}
	done
}
trap onExit EXIT

viewerContainerId=$(docker create osimis/osimis-webviewer-pro:f017049) # CHANGE_VERSION
function removeOsimisWebViewer { docker rm "$viewerContainerId"; }
exitHandlers+=(removeOsimisWebViewer)

docker cp "$viewerContainerId:/usr/share/orthanc/plugins/libOsimisWebViewerPro.so" binaries/plugins-pro/

docker build "$@" --tag=osimis/orthanc-pro:17.6.1 --file=orthanc-pro/Dockerfile . # CHANGE_VERSION
