#!/bin/bash

set -x #to debug the script
set -e #to exit the script at the first failure

# build Windows 32 bits
docker build -t installer-builder-32 --build-arg configurationFile=Orthanc-32.json .
dockerContainerId=$(docker create installer-builder-32)

# copy the orthanc.json generated from the 32 bits version (we can't generate it with wine and Orthanc 64 bits)
docker cp $dockerContainerId:/tmp/OsimisInstaller/orthanc.json .
docker cp $dockerContainerId:/tmp/OsimisInstaller/OrthancInstaller-Win32-22.2.1.exe .  # CHANGE_VERSION_WIN_INSTALLER
docker rm $dockerContainerId

# build Windows 64 bits
docker build -t installer-builder-64 --build-arg configurationFile=Orthanc-64.json .
dockerContainerId=$(docker create installer-builder-64)
docker cp $dockerContainerId:/tmp/OsimisInstaller/OrthancInstaller-Win64-22.2.1.exe .  # CHANGE_VERSION_WIN_INSTALLER
docker rm $dockerContainerId


# upload files to AWS
#####################

# we first need to create the container before we can copy files to it
export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
awsContainerId=$(docker create -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY anigeo/awscli s3 --region eu-west-1 cp /tmp/ s3://orthanc.osimis.io/win-installer/ --recursive --exclude "*" --include "OrthancInstaller*" --cache-control=max-age=1)

# CHANGE_VERSION_WIN_INSTALLER
docker cp OrthancInstaller-Win32-22.2.1.exe $awsContainerId:/tmp   # CHANGE_VERSION_WIN_INSTALLER
docker cp OrthancInstaller-Win64-22.2.1.exe $awsContainerId:/tmp   # CHANGE_VERSION_WIN_INSTALLER

# upload
docker start -a $awsContainerId

# remove container
docker rm $awsContainerId
