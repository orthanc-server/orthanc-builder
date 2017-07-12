#!/usr/bin/env bash
set -o errexit

# Get the number of available cores to speed up the builds
COUNT_CORES=$(grep --count ^processor /proc/cpuinfo)
echo "Will use $COUNT_CORES parallel jobs to build"

# Build Azure Storage Plugin for Orthanc
cd orthanc-blob-storage
git checkout "$1"
mkdir Build
cd Build
BITBUCKET_LICENSINGTOOLBOX_CREDENTIALS=$BITBUCKET_USERINFO \
	cmake -DALLOW_DOWNLOADS=ON \
	    -DSTATIC_BUILD=ON \
	    -DCMAKE_BUILD_TYPE=Release \
	    ..
make "--jobs=$COUNT_CORES"
cp --dereference libOrthancBlobStorage.so /usr/share/orthanc/plugins/
