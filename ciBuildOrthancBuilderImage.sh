#!/bin/bash
# builds the Orthanc images (based on https://github.com/jodogne/OrthancDocker)

set -x #to debug the script
set -e #to exit the script at the first failure

root=${REPOSITORY_PATH:-$(git rev-parse --show-toplevel)}

cd $root/docker/builder

# build the base image (ubuntu + build tools)
docker build -t osimis/orthanc-base base/

# build the orthanc-only image (no plugin)
docker build -t osimis/orthanc-only orthanc/

# build the orthanc-with-open-plugins image
docker build -t osimis/orthanc-with-open-plugins orthanc-plugins/

# build the mssql plugin
git clone https://amazy@bitbucket.org/osimis/orthanc-mssql.git || git pull # TODO: use other credentials !
cd orthanc-mssql
git checkout tags/0.3.8   # CHANGE_VERSION
docker build -t osimis/orthanc-mssql .

# at this stage, you may build the osimis/orthanc image by picking all the required .so files from the latest image 
