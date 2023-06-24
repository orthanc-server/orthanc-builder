#!/usr/bin/env bash
set -ex

# This script is only meant to be run inside Docker during the build process.
# It builds all Orthanc components individually and possibly try to download
# the component before if it has already been built.
# It possibly also uploads the components to orthanc.osimis.io

# example
# for a CI build
# ./build-or-download baseImage=bullseye-20230522-slim commitId=xxxx target=orthanc preferDownloads=1 enableUploads=1
# for a local build
# ./build-or-download.sh target=orthanc baseImage=test commitId=68e15471b408 preferDownloads=1 enableUploads=1


# default arg values
target=unknown
preferDownloads=0
enableUploads=0
baseImage=unknown
commitId=xxx


for argument in "$@"
do
   key=$(echo $argument | cut -f1 -d=)

   key_length=${#key}
   value="${argument:$key_length+1}"

   export "$key"="$value"
done

echo "target             = $target"
echo "preferDownloads    = $preferDownloads"
echo "enableUploads      = $enableUploads"
echo "baseImage          = $baseImage"
echo "commitId           = $commitId"

# while debugging the script on your local machine, you might want to change these paths
buildRootPath=/tmp/build
sourcesRootPath=/tmp/sources
dl=0

# rewrite pushd/popd such that they do not produce any output in bash functions (https://stackoverflow.com/questions/25288194/dont-display-pushd-popd-stack-across-several-bash-scripts-quiet-pushd-popd)
pushd () {
    command pushd "$@" > /dev/null
}

popd () {
    command popd "$@" > /dev/null
}

download() { # $1 file

    mkdir -p $buildRootPath
    already_built=$(($(curl --silent -I https://orthanc.osimis.io/docker-builds/$baseImage/$commitId-$1 | grep -E "^HTTP"     | awk -F " " '{print $2}') == 200))
    if [[ $already_built == 1 ]]; then
        wget "https://orthanc.osimis.io/docker-builds/$baseImage/$commitId-$1" --output-document $buildRootPath/$1
        echo 0
    else
        echo 1
    fi
}

upload() { # $1 file
    echo "uploading $1";

    aws s3 --region eu-west-1 cp $buildRootPath/$1 s3://orthanc.osimis.io/docker-builds/$baseImage/$commitId-$1 --cache-control=max-age=1
}

if [[ $target == "orthanc" ]]; then

    dl=$(expr $dl + $(download Orthanc))
    dl=$(expr $dl + $(download libModalityWorklists.so))
    dl=$(expr $dl + $(download libServeFolders.so))
    dl=$(expr $dl + $(download libHousekeeper.so))
    dl=$(expr $dl + $(download libConnectivityChecks.so))
    dl=$(expr $dl + $(download libDelayedDeletion.so))
    dl=$(expr $dl + $(download libMultitenantDicom.so))

    if [[ $dl != 0 ]]; then

        hg clone https://hg.orthanc-server.com/orthanc/ -r $commitId $sourcesRootPath
        pushd $buildRootPath

        # note: building with static DCMTK while waiting for Debian bullseye to update to latest DCMTK issues (we need DCMTK 3.6.7: https://www.hipaajournal.com/warning-issued-about-3-high-severity-vulnerabilities-in-offis-dicom-software/)
        # also force latest OpenSSL (and therefore, we need to force static libcurl)
        cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DSTANDALONE_BUILD=ON -DUSE_GOOGLE_TEST_DEBIAN_PACKAGE=ON -DUSE_SYSTEM_CIVETWEB=OFF -DUSE_SYSTEM_DCMTK=OFF -DUSE_SYSTEM_OPENSSL=OFF -DUSE_SYSTEM_CURL=OFF $sourcesRootPath/OrthancServer
        make -j 4
        $buildRootPath/UnitTests

        upload Orthanc
    fi

elif [[ $target == "orthanc-authorization" ]]; then

    dl=$(expr $dl + $(download libOrthancAuthorization.so))

    if [[ $dl != 0 ]]; then

        hg clone https://hg.orthanc-server.com/orthanc-authorization/ -r $commitId $sourcesRootPath
        pushd $buildRootPath
        cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF $sourcesRootPath
        make -j 4
        $buildRootPath/UnitTests

        upload libOrthancAuthorization.so
    fi
fi
