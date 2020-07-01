#!/bin/bash

# This script builds the "osimis/orthanc" and "osimis/orthanc-pro"
# images on the local computer (as well as the base images for builds)

set -ex

docker build -t osimis/orthanc-runner-base:current ./orthanc-runner-base/
docker build -t osimis/orthanc-builder-base:current ./orthanc-builder-base/
docker build -t osimis/orthanc:current -f ./orthanc/Dockerfile ./orthanc/
docker build -t osimis/orthanc-pro:current -f ./orthanc-pro-builder/Dockerfile ./orthanc-pro-builder/
