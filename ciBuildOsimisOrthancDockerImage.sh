#!/usr/bin/env bash
set -o errexit
set -o xtrace

cd "${REPOSITORY_PATH:-$(git rev-parse --show-toplevel)}/docker"

while getopts "t:" opt; do
	case "$opt" in
	t) tag=$OPTARG;;
	?) exit 1;;
	esac
done
shift $((OPTIND-1))
if [[ ! $tag ]]; then
	tag=current
fi

mkdir --parents binaries/plugins \
                binaries/plugins-pro \
                binaries/executables

function onExit {
	local -r numHandlers=${#exitHandlers[@]}
	for (( idx = numHandlers - 1; idx >= 0; idx-- )); do
		${exitHandlers[idx]}
	done
}
trap onExit EXIT

orthancContainerId=$(docker create osimis/orthanc-builder-plugins:current)
function removeOrthancBuilder { docker rm "$orthancContainerId"; }
exitHandlers+=(removeOrthancBuilder)

docker cp --follow-link "$orthancContainerId:/usr/share/orthanc/plugins/libOrthancDicomWeb.so" binaries/plugins/
docker cp --follow-link "$orthancContainerId:/usr/share/orthanc/plugins/libOrthancPostgreSQLIndex.so" binaries/plugins/
# TODO docker cp --follow-link "$orthancContainerId:/usr/share/orthanc/plugins/libOrthancPostgreSQLStorage.so" binaries/plugins/
docker cp --follow-link "$orthancContainerId:/usr/share/orthanc/plugins/libOrthancWSI.so" binaries/plugins/
docker cp --follow-link "$orthancContainerId:/usr/share/orthanc/plugins/libOrthancAuthorization.so" binaries/plugins/
docker cp --follow-link "$orthancContainerId:/usr/share/orthanc/plugins/libOrthancWebViewer.so" binaries/plugins/

docker cp --follow-link "$orthancContainerId:/usr/local/share/orthanc/plugins/libModalityWorklists.so" binaries/plugins/libModalityWorklists.so
docker cp --follow-link "$orthancContainerId:/usr/local/share/orthanc/plugins/libServeFolders.so" binaries/plugins/libServeFolders.so

docker cp --follow-link "$orthancContainerId:/usr/local/bin/OrthancRecoverCompressedFile" binaries/executables/
docker cp --follow-link "$orthancContainerId:/usr/local/bin/OrthancWSIDicomToTiff" binaries/executables/
docker cp --follow-link "$orthancContainerId:/usr/local/bin/OrthancWSIDicomizer" binaries/executables/
docker cp --follow-link "$orthancContainerId:/usr/local/sbin/Orthanc" binaries/executables/

viewerContainerId=$(docker create osimis/orthanc-webviewer-plugin:1.1.1)  # CHANGE_VERSION
function removeOsimisWebViewer { docker rm "$viewerContainerId"; }
exitHandlers+=(removeOsimisWebViewer)

docker cp --follow-link "$viewerContainerId:/usr/share/orthanc/plugins/libOsimisWebViewer.so" binaries/plugins/

viewerContainerIdAlpha=$(docker create osimis/orthanc-webviewer-plugin:d77e8286) # CHANGE_VERSION

function removeOsimisWebViewerAlpha { docker rm "$viewerContainerIdAlpha"; }
exitHandlers+=(removeOsimisWebViewerAlpha)

docker cp --follow-link "$viewerContainerIdAlpha:/usr/share/orthanc/plugins/libOsimisWebViewer.so" binaries/plugins/libOsimisWebViewerAlpha.so


wsixContainerId=$(docker create osimis/orthanc-wsi:experimental) # STALE_CACHE
function removeWsix { docker rm "$wsixContainerId"; }
exitHandlers+=(removeWsix)

docker cp --follow-link "$wsixContainerId:/usr/share/orthanc/plugins/libOrthancWSI.so" binaries/plugins/libOrthancWSIx.so

docker build "--tag=docker.io/osimis/orthanc:$tag" --file=orthanc/Dockerfile .

