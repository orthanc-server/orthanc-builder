#!/bin/bash

# to run locally: ./ciBuildWindowsInstaller.sh false test local

set -x #to debug the script
set -e #to exit the script at the first failure


is_tag=${1:-false}
branch_tag_name=${2:-unknown}
type=${3:-local}


# the version must always be X.Y.Z
if [[ $is_tag == "true" ]]; then
    version=$branch_tag_name
else
    version=0.0.0
fi

if [[ $type == "local" ]]; then
    from_cache_arg=
    to_cache_arg=

    # when building locally, use Docker builder (easier to reuse local images)
    build="build"
else
    from_cache_arg="--cache-from=orthancteam/orthanc-builder-base:win-installer"
    to_cache_arg="--cache-to=orthancteam/orthanc-builder-base:win-installer"

    # when building in CI, use buildx
    build="buildx build"
fi


add_host_cmd=--add-host=orthanc.uclouvain.be:130.104.229.21

# docker build --progress=plain -t installer-builder-32 -f Dockerfile --build-arg VERSION=$version --build-arg PLATFORM=32 ..

docker $build \
    $add_host_cmd \
    --progress=plain -t installer-builder-32 \
    --build-arg VERSION=$version \
    --build-arg PLATFORM=32 \
    $from_cache_arg \
    $to_cache_arg \
    -f Dockerfile \
    ..


# build Windows 32 bits
dockerContainerId=$(docker create installer-builder-32)


# copy the orthanc.json generated from the 32 bits version (we can't generate it with wine and Orthanc 64 bits)
docker cp $dockerContainerId:/tmp/OrthancInstaller/orthanc.json .
docker cp $dockerContainerId:/tmp/OrthancInstaller/OrthancInstaller-Win32.exe .
docker rm $dockerContainerId

# build Windows 64 bits
docker $build \
    $add_host_cmd \
    --progress=plain -t installer-builder-64 \
    --build-arg VERSION=$version \
    --build-arg PLATFORM=64 \
    $from_cache_arg \
    $to_cache_arg \
    -f Dockerfile \
    ..


dockerContainerId=$(docker create installer-builder-64)
docker cp $dockerContainerId:/tmp/OrthancInstaller/OrthancInstaller-Win64.exe .
docker rm $dockerContainerId


# upload files to AWS
#####################

# we first need to create the container before we can copy files to it
export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
awsContainerId=$(docker create $add_host_cmd -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY anigeo/awscli s3 --region eu-west-1 cp /tmp/ s3://public-files.orthanc.team/tmp-builds/win-installer/ --recursive --exclude "*" --include "OrthancInstaller*" --cache-control=max-age=1)

# CHANGE_VERSION_WIN_INSTALLER
docker cp OrthancInstaller-Win32.exe $awsContainerId:/tmp/OrthancInstaller-Win32-$branch_tag_name.exe
docker cp OrthancInstaller-Win64.exe $awsContainerId:/tmp/OrthancInstaller-Win64-$branch_tag_name.exe

if [[ $is_tag == "true" ]]; then
    docker cp OrthancInstaller-Win32.exe $awsContainerId:/tmp/OrthancInstaller-Win32-latest.exe
    docker cp OrthancInstaller-Win64.exe $awsContainerId:/tmp/OrthancInstaller-Win64-latest.exe
fi

# upload
docker start -a $awsContainerId

# remove container
docker rm $awsContainerId
