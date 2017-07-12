#!/bin/bash
# builds the Orthanc images (based on https://github.com/jodogne/OrthancDocker)

set -x #to debug the script
set -e #to exit the script at the first failure

root=${REPOSITORY_PATH:-$(git rev-parse --show-toplevel)}

cd $root/docker/builder

# build the base image (ubuntu + build tools)
docker build --tag=osimis/orthanc-builder-base base

# build the orthanc-builder image (no plugin)
docker build --tag=osimis/orthanc-builder \
	--build-arg=ORTHANC_VERSION=Orthanc-1.2.0 \
	orthanc
# CHANGE_VERSION (official version is someting like Orthanc-1.2.0)

# build the orthanc-builder-plugins image
docker build --tag=osimis/orthanc-builder-plugins \
	orthanc-plugins

# at this stage, you may build the osimis/orthanc image by picking all the required .so files from the latest image 
