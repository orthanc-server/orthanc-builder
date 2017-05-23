#!/bin/bash

set -x #to debug the script
set -e #to exit the script at the first failure

root=${REPOSITORY_PATH:-$(git rev-parse --show-toplevel)}

cd $root/docker

mkdir -p binaries
mkdir -p binaries/plugins
mkdir -p binaries/plugins-pro
mkdir -p binaries/executables


containerId=$(docker create osimis/orthanc-with-open-plugins)
docker cp $containerId:/usr/share/orthanc/plugins/libOrthancDicomWeb.so binaries/plugins/
docker cp $containerId:/usr/share/orthanc/plugins/libOrthancPostgreSQLIndex.so binaries/plugins/
docker cp $containerId:/usr/share/orthanc/plugins/libOrthancPostgreSQLStorage.so binaries/plugins/
docker cp $containerId:/usr/share/orthanc/plugins/libOrthancWSI.so binaries/plugins/
docker cp $containerId:/usr/share/orthanc/plugins/libOrthancWebViewer.so binaries/plugins/
docker cp $containerId:/usr/share/orthanc/plugins/libOrthancAuthorization.so binaries/plugins/


docker cp $containerId:/usr/local/share/orthanc/plugins/libModalityWorklists.so.1.2.0 binaries/plugins/libModalityWorklists.so  # CHANGE_VERSION
docker cp $containerId:/usr/local/share/orthanc/plugins/libServeFolders.so.1.2.0 binaries/plugins/libServeFolders.so  # CHANGE_VERSION

docker cp $containerId:/usr/local/bin/OrthancRecoverCompressedFile binaries/executables/
docker cp $containerId:/usr/local/bin/OrthancWSIDicomToTiff binaries/executables/
docker cp $containerId:/usr/local/bin/OrthancWSIDicomizer binaries/executables/
docker cp $containerId:/usr/local/sbin/Orthanc binaries/executables/

containerId=$(docker create osimis/orthanc-webviewer-plugin:am-static-build-0.8.0)  # CHANGE_VERSION
docker cp $containerId:/usr/share/orthanc/plugins/libOsimisWebViewer.so binaries/plugins/


docker build $@ -t osimis/orthanc:17.5.alpha -f orthanc/Dockerfile .  # CHANGE_VERSION

# docker push osimis/orthanc:17.5.alpha # CHANGE_VERSION