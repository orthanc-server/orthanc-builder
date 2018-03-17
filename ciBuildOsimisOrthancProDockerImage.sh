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

# let's build the 'pro image'
mkdir --parents binaries/plugins-{pro,deps}

# fetch mssql so file
mssqlPlugin=binaries/plugins-pro/libOrthancMsSqlIndex.so
if [[ ! -e $mssqlPlugin ]]; then
	# CHANGE_VERSION (MSSQL)
	wget orthanc.osimis.io/docker-so/mssql/0.6.1/libOrthancMsSqlIndex.so \
		--output-document "$mssqlPlugin"
fi

function onExit {
	local -r numHandlers=${#exitHandlers[@]}
	for (( idx = numHandlers - 1; idx >= 0; idx-- )); do
		${exitHandlers[idx]}
	done
}
trap onExit EXIT

viewerContainerId=$(docker create osimis/osimis-webviewer-pro:release-1.0.2.0) # CHANGE_VERSION
function removeOsimisWebViewer { docker rm "$viewerContainerId"; }
exitHandlers+=(removeOsimisWebViewer)

docker cp --follow-link "$viewerContainerId:/usr/share/orthanc/plugins/libOsimisWebViewerPro.so" binaries/plugins-pro/

viewerContainerIdAlpha=$(docker create osimis/osimis-webviewer-pro:ae8b463) # CHANGE_VERSION
function removeOsimisWebViewerAlpha { docker rm "$viewerContainerIdAlpha"; }
exitHandlers+=(removeOsimisWebViewerAlpha)

docker cp --follow-link "$viewerContainerIdAlpha:/usr/share/orthanc/plugins/libOsimisWebViewerPro.so" binaries/plugins-pro/libOsimisWebViewerProAlpha.so

orthancContainerId=$(docker create osimis/orthanc-builder-plugins:current)
function removeOrthancBuilder { docker rm "$orthancContainerId"; }
exitHandlers+=(removeOrthancBuilder)

docker cp --follow-link "$orthancContainerId:/usr/share/orthanc/plugins/libOrthancBlobStorage.so" binaries/plugins-pro/
docker cp --follow-link "$orthancContainerId:/usr/local/lib/libazurestorage.so.3" binaries/plugins-deps/
docker cp --follow-link "$orthancContainerId:/usr/local/lib/libcpprest.so.2.9" binaries/plugins-deps/

docker build "--tag=docker.io/osimis/orthanc-pro:$tag" --file=orthanc-pro/Dockerfile .  # CHANGE_VERSION
