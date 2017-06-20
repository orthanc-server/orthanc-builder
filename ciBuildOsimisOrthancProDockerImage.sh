#!/bin/bash

set -x #to debug the script
set -e #to exit the script at the first failure

root=${REPOSITORY_PATH:-$(git rev-parse --show-toplevel)}

cd $root/docker

# let's build the 'pro image'
mkdir -p binaries/plugins-pro

# fetch mssql so file
wget orthanc.osimis.io/docker-so/mssql/0.4.1/libOrthancMsSqlIndex.so -O binaries/plugins-pro/libOrthancMsSqlIndex.so # CHANGE_VERSION

function onExit {
	local -r numHandlers=${#exitHandlers[@]}
	for (( idx = numHandlers - 1; idx >= 0; idx-- )); do
		${exitHandlers[idx]}
	done
}
trap onExit EXIT


viewerContainerId=$(docker create osimis/osimis-webviewer-pro:f017049) # CHANGE_VERSION
function removeOsimisWebViewer { docker rm $viewerContainerId; }
exitHandlers+=(removeOsimisWebViewer)

docker cp $viewerContainerId:/usr/share/orthanc/plugins/libOsimisWebViewerPro.so binaries/plugins-pro/

docker build $@ -t osimis/orthanc-pro:17.6.1 -f orthanc-pro/Dockerfile . # CHANGE_VERSION