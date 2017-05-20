#!/bin/bash

set -x #to debug the script
set -e #to exit the script at the first failure

mkdir -p binaries
mkdir -p binaries/plugins
mkdir -p binaries/executables

containerId=$(docker create jodogne/orthanc-plugins:1.2.0)
docker cp $containerId:/usr/share/orthanc/plugins/libOrthancDicomWeb.so binaries/plugins/
docker cp $containerId:/usr/share/orthanc/plugins/libOrthancPostgreSQLIndex.so binaries/plugins/
docker cp $containerId:/usr/share/orthanc/plugins/libOrthancPostgreSQLStorage.so binaries/plugins/
docker cp $containerId:/usr/share/orthanc/plugins/libOrthancWSI.so binaries/plugins/
docker cp $containerId:/usr/share/orthanc/plugins/libOrthancWebViewer.so binaries/plugins/

docker cp $containerId:/usr/local/share/orthanc/plugins/libModalityWorklists.so.1.2.0 binaries/plugins/libModalityWorklists.so
docker cp $containerId:/usr/local/share/orthanc/plugins/libServeFolders.so.1.2.0 binaries/plugins/libServeFolders.so

docker cp $containerId:/usr/local/bin/OrthancRecoverCompressedFile binaries/executables/
docker cp $containerId:/usr/local/bin/OrthancWSIDicomToTiff binaries/executables/
docker cp $containerId:/usr/local/bin/OrthancWSIDicomizer binaries/executables/
docker cp $containerId:/usr/local/sbin/Orthanc binaries/executables/

containerId=$(docker create osimis/orthanc-webviewer-plugin:0.8.0)
docker cp $containerId:/usr/share/orthanc/plugins/libOsimisWebViewer.so binaries/plugins/

containerId=$(docker create osimis/orthanc-webviewer-plugin:0.8.0)
docker cp $containerId:/usr/share/orthanc/plugins/libOsimisWebViewer.so binaries/plugins/

docker build -t osimis/orthanc:17.5.alpha .

docker push osimis/orthanc:17.5.alpha

# let's build the 'pro image'
# mkdir -p binaries/plugins-pro
# containerId=$(docker create 7da685196393)  # TODO: should be an mssql image !
# docker cp $containerId:/usr/share/orthanc/plugins/ .. mssql.so  binaries/plugins-pro/
#
# docker build -t osimis/orthanc-pro:17.5.alpha