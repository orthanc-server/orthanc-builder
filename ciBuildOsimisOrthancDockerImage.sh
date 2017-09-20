#!/usr/bin/env bash
set -o errexit
set -o xtrace

cd "${REPOSITORY_PATH:-$(git rev-parse --show-toplevel)}/docker"

mkdir --parents binaries/plugins \
                binaries/plugins-pro \
                binaries/plugins-disabled \
                binaries/executables

function onExit {
	local -r numHandlers=${#exitHandlers[@]}
	for (( idx = numHandlers - 1; idx >= 0; idx-- )); do
		${exitHandlers[idx]}
	done
}
trap onExit EXIT

orthancContainerId=$(docker create osimis/orthanc-builder-plugins)
function removeOrthancBuilder { docker rm "$orthancContainerId"; }
exitHandlers+=(removeOrthancBuilder)

docker cp --follow-link "$orthancContainerId:/usr/share/orthanc/plugins/libOrthancDicomWeb.so" binaries/plugins/
docker cp --follow-link "$orthancContainerId:/usr/share/orthanc/plugins/libOrthancPostgreSQLIndex.so" binaries/plugins/
docker cp --follow-link "$orthancContainerId:/usr/share/orthanc/plugins/libOrthancPostgreSQLStorage.so" binaries/plugins/
docker cp --follow-link "$orthancContainerId:/usr/share/orthanc/plugins/libOrthancWSI.so" binaries/plugins/
docker cp --follow-link "$orthancContainerId:/usr/share/orthanc/plugins/libOrthancAuthorization.so" binaries/plugins/
docker cp --follow-link "$orthancContainerId:/usr/share/orthanc/plugins/libOrthancWebViewer.so" binaries/plugins-disabled/

docker cp --follow-link "$orthancContainerId:/usr/local/share/orthanc/plugins/libModalityWorklists.so" binaries/plugins/libModalityWorklists.so
docker cp --follow-link "$orthancContainerId:/usr/local/share/orthanc/plugins/libServeFolders.so" binaries/plugins/libServeFolders.so

docker cp --follow-link "$orthancContainerId:/usr/local/bin/OrthancRecoverCompressedFile" binaries/executables/
docker cp --follow-link "$orthancContainerId:/usr/local/bin/OrthancWSIDicomToTiff" binaries/executables/
docker cp --follow-link "$orthancContainerId:/usr/local/bin/OrthancWSIDicomizer" binaries/executables/
docker cp --follow-link "$orthancContainerId:/usr/local/sbin/Orthanc" binaries/executables/

viewerContainerId=$(docker create osimis/orthanc-webviewer-plugin:1.0.0)  # CHANGE_VERSION
function removeOsimisWebViewer { docker rm "$viewerContainerId"; }
exitHandlers+=(removeOsimisWebViewer)

docker cp --follow-link "$viewerContainerId:/usr/share/orthanc/plugins/libOsimisWebViewer.so" binaries/plugins/

docker build --tag=osimis/orthanc:17.8.0-alpha --file=orthanc/Dockerfile .  # CHANGE_VERSION
