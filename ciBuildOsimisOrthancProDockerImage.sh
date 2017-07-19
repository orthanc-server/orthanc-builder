#!/usr/bin/env bash
set -o errexit
set -o xtrace

cd "${REPOSITORY_PATH:-$(git rev-parse --show-toplevel)}/docker"

# let's build the 'pro image'
mkdir --parents binaries/plugins-{pro,deps}

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

viewerContainerId=$(docker create osimis/osimis-webviewer-pro:bd0f243) # CHANGE_VERSION
function removeOsimisWebViewer { docker rm "$viewerContainerId"; }
exitHandlers+=(removeOsimisWebViewer)

docker cp --follow-link "$viewerContainerId:/usr/share/orthanc/plugins/libOsimisWebViewerPro.so" binaries/plugins-pro/

orthancContainerId=$(docker create osimis/orthanc-builder-plugins)
function removeOrthancBuilder { docker rm "$orthancContainerId"; }
exitHandlers+=(removeOrthancBuilder)

docker cp --follow-link "$orthancContainerId:/usr/share/orthanc/plugins/libOrthancBlobStorage.so" binaries/plugins-pro/
docker cp --follow-link "$orthancContainerId:/usr/local/lib/libazurestorage.so.3" binaries/plugins-deps/
docker cp --follow-link "$orthancContainerId:/usr/local/lib/libcpprest.so.2.9" binaries/plugins-deps/

docker build --tag=osimis/orthanc-pro:17.7-ern --file=orthanc-pro/Dockerfile . # CHANGE_VERSION
