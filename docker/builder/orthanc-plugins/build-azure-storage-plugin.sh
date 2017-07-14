#!/usr/bin/env bash
set -o errexit

# Get the number of available cores to speed up the builds
COUNT_CORES=$(grep --count ^processor /proc/cpuinfo)
echo "Will use $COUNT_CORES parallel jobs to build"

# Build Azure Storage Plugin for Orthanc
git clone "--branch=$1" \
	--single-branch \
	"https://$BITBUCKET_USERINFO@bitbucket.org/osimis/orthanc-blob-storage.git"
cd orthanc-blob-storage
mkdir Build
cd Build
BITBUCKET_LICENSINGTOOLBOX_CREDENTIALS=$BITBUCKET_USERINFO \
	cmake -DALLOW_DOWNLOADS=ON \
	    -DSTATIC_BUILD=ON \
	    -DCMAKE_BUILD_TYPE=Release \
	    ..
make "--jobs=$COUNT_CORES"
ln --logical libOrthancBlobStorage.so /usr/share/orthanc/plugins/
