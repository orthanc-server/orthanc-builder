#!/bin/bash

set -ex

is_tag=${1:-false}
<<<<<<< HEAD
branch_tag_name=${2:-22.3.0}       # CHANGE_VERSION_OSX
download_from_buildbot=${3:-true}  # if false, we consider that binaries are already in /tmp/osx-package/Orthanc-OSX-$branch_tag_name

=======
branch_tag_name=${2:-unknown}

# CHANGE_VERSION_OSX
VERSION=22.3.0
>>>>>>> master

URL='https://alain:koo4oCah@buildbot.orthanc-server.com/artifacts/Binaries/'
TARGET='/tmp/osx-package/'
FOLDER=Orthanc-OSX-$branch_tag_name


# https://stackoverflow.com/a/4774063/881731
SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

if [[ $download_from_buildbot == "true" ]]; then
    rm -rf ${TARGET}/${FOLDER} 
    mkdir -p ${TARGET}/${FOLDER}
fi

cd ${TARGET}/${FOLDER}

# Resources
cp ${SCRIPTPATH}/orthancBuildResources/configOSX.json .
cp ${SCRIPTPATH}/orthancBuildResources/readmeOSX.txt readme.txt
cp ${SCRIPTPATH}/orthancBuildResources/startOrthanc.command .
cp ${SCRIPTPATH}/WindowsInstaller/Resources/ca-certificates.crt .

if [[ $download_from_buildbot == "true" ]]; then

    # Orthanc core
    wget "${URL}/Orthanc 1.10.1 - OS X Release/Orthanc"
    wget "${URL}/Orthanc 1.10.1 - OS X Release/libModalityWorklists.dylib"
    wget "${URL}/Orthanc 1.10.1 - OS X Release/libServeFolders.dylib"
    wget "${URL}/Orthanc 1.10.1 - OS X Release/libConnectivityChecks.dylib"

    # Plugins
    wget "${URL}/DicomWeb 1.7 - OS X Release/libOrthancDicomWeb.dylib"
    wget "${URL}/MySQL 4.3 - OS X Release/libOrthancMySQLIndex.dylib"
    wget "${URL}/MySQL 4.3 - OS X Release/libOrthancMySQLStorage.dylib"
    wget "${URL}/PostgreSQL 4.0 - OS X Release/libOrthancPostgreSQLIndex.dylib"
    wget "${URL}/PostgreSQL 4.0 - OS X Release/libOrthancPostgreSQLStorage.dylib"
    wget "${URL}/Transfers 1.0 - OS X Release/libOrthancTransfers.dylib"
    wget "${URL}/WebViewer 2.8 - OS X Release/libOrthancWebViewer.dylib"
    wget "${URL}/Stone 2.3 - OS X Release/libStoneWebViewer.dylib"
    wget "${URL}/Gdcm 1.5 - OS X Release/libOrthancGdcm.dylib"
    wget "${URL}/Odbc 1.1 - OS X Release/libOrthancOdbcIndex.dylib"
    wget "${URL}/Odbc 1.1 - OS X Release/libOrthancOdbcStorage.dylib"
    wget "${URL}/Tcia 1.1 - OS X Release/libOrthancTcia.dylib"
    wget "${URL}/FolderIndexer 1.0 - OS X Release/libOrthancIndexer.dylib"

fi

# these plugins are not built by GitHub so download them:
wget "${URL}/OsimisWebViewer 1.4.2 - OS X Release/libOsimisWebViewer.dylib"
wget "${URL}/WSI 1.1 - OS X Release/libOrthancWSI.dylib"


chmod +x ./Orthanc

# Create the archive
cd ${TARGET}
zip -r ${FOLDER}.zip ${FOLDER}
echo -e "\nThe archive can be found at: ${TARGET}/${FOLDER}.zip\n"

# upload files to AWS
#####################

<<<<<<< HEAD
aws s3 --region eu-west-1 cp /tmp/osx-package/ s3://orthanc.osimis.io/osx/releases/ --recursive --exclude "*" --include "Orthanc-OSX*.zip" --cache-control=max-age=1
=======
# we first need to create the container before we can copy files to it
export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
awsContainerId=$(docker create -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY anigeo/awscli s3 --region eu-west-1 cp /tmp/ s3://orthanc.osimis.io/osx/releases/ --recursive --exclude "*" --include "Orthanc-OSX*" --cache-control=max-age=1)

# CHANGE_VERSION_WIN_INSTALLER
docker cp ${TARGET}/${FOLDER}.zip $awsContainerId:/tmp
>>>>>>> master

if [[ $is_tag == "true" ]]; then
    
    cp ${TARGET}/${FOLDER}.zip ${TARGET}/orthancAndPluginsOSX.stable.zip
    aws s3 --region eu-west-1 cp /tmp/osx-package/ s3://orthanc.osimis.io/osx/stable/ --recursive --exclude "*" --include "orthancAndPluginsOSX*" --cache-control=max-age=1

<<<<<<< HEAD
=======
# remove container
docker rm $awsContainerId

if [[ $is_tag == "true" ]]; then
    awsContainerId=$(docker create -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY anigeo/awscli s3 --region eu-west-1 cp /tmp/ s3://orthanc.osimis.io/osx/stable/ --recursive --exclude "*" --include "orthancAndPluginsOSX*" --cache-control=max-age=1)

    docker cp ${TARGET}/${FOLDER}.zip $awsContainerId:/tmp/orthancAndPluginsOSX.stable.zip

    # upload
    docker start -a $awsContainerId

    # remove container
    docker rm $awsContainerId
>>>>>>> master
fi
