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
	wget orthanc.osimis.io/docker-so/mssql/0.5.0/libOrthancMsSqlIndex.so \
		--output-document "$mssqlPlugin"
fi

function onExit {
	local -r numHandlers=${#exitHandlers[@]}
	for (( idx = numHandlers - 1; idx >= 0; idx-- )); do
		${exitHandlers[idx]}
	done
}
trap onExit EXIT

viewerContainerId=$(docker create osimis/osimis-webviewer-pro:1.0.0.99) # CHANGE_VERSION
function removeOsimisWebViewer { docker rm "$viewerContainerId"; }
exitHandlers+=(removeOsimisWebViewer)

docker cp --follow-link "$viewerContainerId:/usr/share/orthanc/plugins/libOsimisWebViewerPro.so" binaries/plugins-pro/

viewerContainerIdAlpha=$(docker create osimis/osimis-webviewer-pro:release-1.1.0.0) # CHANGE_VERSION
function removeOsimisWebViewerAlpha { docker rm "$viewerContainerIdAlpha"; }
exitHandlers+=(removeOsimisWebViewerAlpha)

docker cp --follow-link "$viewerContainerIdAlpha:/usr/share/orthanc/plugins/libOsimisWebViewerPro.so" binaries/plugins-pro/libOsimisWebViewerProAlpha.so

orthancContainerId=$(docker create osimis/orthanc-builder-plugins)
function removeOrthancBuilder { docker rm "$orthancContainerId"; }
exitHandlers+=(removeOrthancBuilder)

docker cp --follow-link "$orthancContainerId:/usr/share/orthanc/plugins/libOrthancBlobStorage.so" binaries/plugins-pro/
docker cp --follow-link "$orthancContainerId:/usr/local/lib/libazurestorage.so.3" binaries/plugins-deps/
docker cp --follow-link "$orthancContainerId:/usr/local/lib/libcpprest.so.2.9" binaries/plugins-deps/

docker build --tag=osimis/orthanc-pro:17.9.4-alpha --file=orthanc-pro/Dockerfile . # CHANGE_VERSION
