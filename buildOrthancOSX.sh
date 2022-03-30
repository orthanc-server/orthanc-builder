#!/bin/bash

set -ex

is_tag=${1:-false}
branch_tag_name=${2:-22.3.0}       # CHANGE_VERSION_OSX
download_from_buildbot=${3:-true}  # if false, we consider that binaries are already in /tmp/osx-package/Orthanc-OSX-$branch_tag_name

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

    # CHANGE_VERSION_ORTHANC
    wget "${URL}/Orthanc 1.10.1 - OS X Release/Orthanc"
    wget "${URL}/Orthanc 1.10.1 - OS X Release/libModalityWorklists.dylib"
    wget "${URL}/Orthanc 1.10.1 - OS X Release/libServeFolders.dylib"
    wget "${URL}/Orthanc 1.10.1 - OS X Release/libConnectivityChecks.dylib"

    # CHANGE_VERSION_DW
    wget "${URL}/DicomWeb 1.7 - OS X Release/libOrthancDicomWeb.dylib"
    
    # CHANGE_VERSION_MYSQL
    wget "${URL}/MySQL 4.3 - OS X Release/libOrthancMySQLIndex.dylib"
    wget "${URL}/MySQL 4.3 - OS X Release/libOrthancMySQLStorage.dylib"
    
    # CHANGE_VERSION_PG
    wget "${URL}/PostgreSQL 4.0 - OS X Release/libOrthancPostgreSQLIndex.dylib"
    wget "${URL}/PostgreSQL 4.0 - OS X Release/libOrthancPostgreSQLStorage.dylib"
    
    # CHANGE_VERSION_TRANSFERS
    wget "${URL}/Transfers 1.0 - OS X Release/libOrthancTransfers.dylib"
    
    # CHANGE_VERSION_ORTHANC_WEB_VIEWER
    wget "${URL}/WebViewer 2.8 - OS X Release/libOrthancWebViewer.dylib"
    
    # CHANGE_VERSION_STONE_WEB_VIEWER
    wget "${URL}/Stone 2.3 - OS X Release/libStoneWebViewer.dylib"
    
    # CHANGE_VERSION_GDCM
    wget "${URL}/Gdcm 1.5 - OS X Release/libOrthancGdcm.dylib"
    
    # CHANGE_VERSION_ODBC
    wget "${URL}/Odbc 1.1 - OS X Release/libOrthancOdbcIndex.dylib"
    wget "${URL}/Odbc 1.1 - OS X Release/libOrthancOdbcStorage.dylib"
    
    # CHANGE_VERSION_TCIA
    wget "${URL}/Tcia 1.1 - OS X Release/libOrthancTcia.dylib"
    
    # CHANGE_VERSION_INDEXER
    wget "${URL}/FolderIndexer 1.0 - OS X Release/libOrthancIndexer.dylib"


    # these plugins are not built by GitHub so the downloaded files only contain AMD64 binary (TODO)
    
    # CHANGE_VERSION_WVB
    wget "${URL}/OsimisWebViewer 1.4.2 - OS X Release/libOsimisWebViewer.dylib"
    
    # CHANGE_VERSION_WSI
    wget "${URL}/WSI 1.1 - OS X Release/libOrthancWSI.dylib"
fi

# download universal binaries
# CHANGE_VERSION_ORTHANC_EXPLORER_2
wget "https://github.com/orthanc-server/orthanc-explorer-2/releases/download/0.1.3/libOrthancExplorer2-universal.dylib"



chmod +x ./Orthanc

# Create the archive
cd ${TARGET}
zip -r ${FOLDER}.zip ${FOLDER}
echo -e "\nThe archive can be found at: ${TARGET}/${FOLDER}.zip\n"

# upload files to AWS
#####################

aws s3 --region eu-west-1 cp /tmp/osx-package/ s3://orthanc.osimis.io/osx/releases/ --recursive --exclude "*" --include "Orthanc-OSX*.zip" --cache-control=max-age=1

if [[ $is_tag == "true" ]]; then
    
    cp ${TARGET}/${FOLDER}.zip ${TARGET}/orthancAndPluginsOSX.stable.zip
    aws s3 --region eu-west-1 cp /tmp/osx-package/ s3://orthanc.osimis.io/osx/stable/ --recursive --exclude "*" --include "orthancAndPluginsOSX*" --cache-control=max-age=1

fi
