#!/bin/bash

set -ex

# CHANGE_VERSION_OSX
VERSION=22.2.1

URL='https://alain:koo4oCah@buildbot.orthanc-server.com/artifacts/Binaries/'
TARGET='/tmp/'
FOLDER=Orthanc-OSX-$VERSION

# https://stackoverflow.com/a/4774063/881731
SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

rm -rf ${TARGET}/${FOLDER} 
mkdir ${TARGET}/${FOLDER}
cd ${TARGET}/${FOLDER}

# Resources
cp ${SCRIPTPATH}/orthancBuildResources/configOSX.json .
cp ${SCRIPTPATH}/orthancBuildResources/readmeOSX.txt readme.txt
cp ${SCRIPTPATH}/orthancBuildResources/startOrthanc.command .
cp ${SCRIPTPATH}/WindowsInstaller/Resources/ca-certificates.crt .

# Orthanc core
wget "${URL}/Orthanc 1.10.1 - OS X Release/Orthanc"
wget "${URL}/Orthanc 1.10.1 - OS X Release/libModalityWorklists.dylib"
wget "${URL}/Orthanc 1.10.1 - OS X Release/libServeFolders.dylib"
wget "${URL}/Orthanc 1.10.1 - OS X Release/libConnectivityChecks.dylib"

chmod +x ./Orthanc

# Plugins
wget "${URL}/DicomWeb 1.7 - OS X Release/libOrthancDicomWeb.dylib"
wget "${URL}/MySQL 4.3 - OS X Release/libOrthancMySQLIndex.dylib"
wget "${URL}/MySQL 4.3 - OS X Release/libOrthancMySQLStorage.dylib"
wget "${URL}/OsimisWebViewer 1.4.2 - OS X Release/libOsimisWebViewer.dylib"
wget "${URL}/PostgreSQL 4.0 - OS X Release/libOrthancPostgreSQLIndex.dylib"
wget "${URL}/PostgreSQL 4.0 - OS X Release/libOrthancPostgreSQLStorage.dylib"
wget "${URL}/Transfers 1.0 - OS X Release/libOrthancTransfers.dylib"
wget "${URL}/WebViewer 2.8 - OS X Release/libOrthancWebViewer.dylib"
wget "${URL}/Stone 2.2 - OS X Release/libStoneWebViewer.dylib"
wget "${URL}/Gdcm 1.4 - OS X Release/libOrthancGdcm.dylib"
wget "${URL}/WSI 1.1 - OS X Release/libOrthancWSI.dylib"
wget "${URL}/Odbc 1.1 - OS X Release/libOrthancOdbcIndex.dylib"
wget "${URL}/Odbc 1.1 - OS X Release/libOrthancOdbcStorage.dylib"
wget "${URL}/Tcia 1.1 - OS X Release/libOrthancTcia.dylib"
wget "${URL}/FolderIndexer 1.0 - OS X Release/libOrthancIndexer.dylib"

# Create the archive
cd ${TARGET}
zip -r ${FOLDER}.zip ${FOLDER}
echo -e "\nThe archive can be found at: ${TARGET}/${FOLDER}.zip\n"


# upload files to AWS
#####################

# we first need to create the container before we can copy files to it
echo $AWS_ACCESS_KEY_ID
export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
awsContainerId=$(docker create -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY anigeo/awscli s3 --region eu-west-1 cp /tmp/ s3://orthanc.osimis.io/osx/releases/ --recursive --exclude "*" --include "Orthanc-OSX*" --cache-control=max-age=1)

# CHANGE_VERSION_WIN_INSTALLER
docker cp ${TARGET}/${FOLDER}.zip $awsContainerId:/tmp

# upload
docker start -a $awsContainerId

# remove container
docker rm $awsContainerId
