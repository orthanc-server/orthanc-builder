#!/usr/bin/env bash
#
# build Docker images and eventually pushes them to DockerHub
# example usage:
# ./build.sh 17.10.1 true true

set -o errexit
set -o xtrace

./ciBuildOrthancBuilderImage.sh
./ciBuildOsimisOrthancDockerImage.sh
./ciBuildOsimisOrthancProDockerImage.sh

version=$1
tagLatest=${2:-false}
push=${3:-false}

if [[ ! $version ]]; then
	echo "please provide a tag in argument" >&2
	exit 1
fi

docker tag osimis/orthanc:current osimis/orthanc:"$version"
docker tag osimis/orthanc-pro:current osimis/orthanc-pro:"$version"

if [[ $push == true ]]; then
	docker push osimis/orthanc:"$version"
	docker push osimis/orthanc-pro:"$version"
fi

if [[ $tagLatest == true ]]; then
	docker tag osimis/orthanc:current osimis/orthanc:latest
	docker tag osimis/orthanc-pro:current osimis/orthanc-pro:latest

	if [[ $push == true ]]; then
		docker push osimis/orthanc:latest
		docker push osimis/orthanc-pro:latest
	fi
fi
