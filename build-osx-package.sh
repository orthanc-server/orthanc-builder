#!/bin/bash

# sample command
# ./build-osx-package.sh stable_unstable=stable is_tag=false current_branch_tag=master

set -ex

# https://stackoverflow.com/a/4774063/881731
SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

source $SCRIPTPATH/bash-helpers.sh

for argument in "$@"
do
   key=$(echo $argument | cut -f1 -d=)

   key_length=${#key}
   value="${argument:$key_length+1}"

   export "$key"="$value"
done


echo "stable_unstable = $stable_unstable"
echo "current_branch_tag = $current_branch_tag"
echo "is_tag = $is_tag"

TARGET='/tmp/osx-package/'
FOLDER=Orthanc-OSX-$current_branch_tag-$stable_unstable


rm -rf ${TARGET}/${FOLDER} 
mkdir -p ${TARGET}/${FOLDER}

# Resources
cp ${SCRIPTPATH}/orthancBuildResources/configOSX.json ${TARGET}/${FOLDER}
cp ${SCRIPTPATH}/orthancBuildResources/readmeOSX.txt ${TARGET}/${FOLDER}/readme.txt
cp ${SCRIPTPATH}/orthancBuildResources/startOrthanc.command ${TARGET}/${FOLDER}
cp ${SCRIPTPATH}/WindowsInstaller/Resources/ca-certificates.crt ${TARGET}/${FOLDER}


downloadArtifactsFromOrthancOsimisIo() { # $1 config_name
    echo "downloading $1";

    artifacts=$(getArtifactsOSX $1 $stable_unstable)
    branchTag=$(getBranchTagToBuildOSX $1 $stable_unstable)
 
    for artifact in $artifacts; do
        wget "https://orthanc.osimis.io/nightly-osx-builds/$branchTag/$artifact" --output-document ${TARGET}/${FOLDER}/$artifact
    done
}

downloadArtifacts() { # $1 config_name $2 root_download_for_osx
    echo "downloading $1 $2";
    artifacts=$(getArtifactsOSX $1 $stable_unstable)
    branchTag=$(getBranchTagToBuildOSX $1 $stable_unstable)
 
    for artifact in $artifacts; do
        wget "$2/$branchTag/$artifact" --output-document ${TARGET}/${FOLDER}/$artifact
    done
}

# extract tuple from build-matrix and cycle through all config
while read -r config_name build_for_osx root_download_for_osx; do
    
    echo $config_name $build_for_osx $root_download_for_osx
    
    if [[ "$build_for_osx" == "true" ]]; then
        downloadArtifactsFromOrthancOsimisIo $config_name
    elif [[ "$root_download_for_osx" != "null" ]]; then
        downloadArtifacts $config_name $root_download_for_osx
    fi

done< <(cat $SCRIPTPATH/build-matrix.json | jq -r '.configs[] | "\(.name) \(.buildForOSX) \(.rootDownloadForOSX)"')

# # TODO these plugins are not built by GitHub so the downloaded files only contain AMD64 binary (TODO)
# # CHANGE_VERSION_WSI
# wget "${URL}/WSI 2.0 - OS X Release/libOrthancWSI.dylib"

chmod +x ${TARGET}/${FOLDER}/Orthanc

# Create the archive
cd ${TARGET}
zip -r ${FOLDER}.zip ${FOLDER}
echo -e "\nThe archive can be found at: ${TARGET}/${FOLDER}.zip\n"

# upload files to AWS
#####################

if [[ $is_tag == "true" ]] && [[ $stable_unstable == "stable" ]]; then
    
    cp ${TARGET}/${FOLDER}.zip ${TARGET}/orthancAndPluginsOSX.stable.zip
    aws s3 --region eu-west-1 cp /tmp/osx-package/ s3://orthanc.osimis.io/osx/stable/ --recursive --exclude "*" --include "orthancAndPluginsOSX*" --cache-control=max-age=1

    cp ${TARGET}/${FOLDER}.zip ${TARGET}/Orthanc-OSX-$current_branch_tag.zip
fi

aws s3 --region eu-west-1 cp /tmp/osx-package/ s3://orthanc.osimis.io/osx/releases/ --recursive --exclude "*" --include "Orthanc-OSX*.zip" --cache-control=max-age=1
