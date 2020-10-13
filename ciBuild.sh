#!/usr/bin/env bash
#
# builds osimis/orthanc and osimis/orthanc-pro images from CI
#
# usage:
# ciBuild.sh ${BRANCH_NAME}

set -o errexit
set -o xtrace

# make sure we use the latest ubuntu image (which is the base of everything we build)
# note: this has been removed now that we use a fixed base image.
# instead of pulling, update the tag in docker\orthanc-runner-base\Dockerfile
# docker pull debian:buster

git submodule init
git submodule update

# Retrieve git metadata
gitLongTag=$(git describe --long --dirty=-dirty)
branchName=${1:-$(git rev-parse --abbrev-ref HEAD)} #if no argument defined, get the branch name from git
action=${2:-build}  # build, pushToPublicRepo or pushToPrivateRepo
releaseCommitId=$(git rev-parse --short HEAD)
isLatest=false

if [[ $gitLongTag =~ dirty ]]; then
	echo "commit your changes before building"
	exit -1
fi

if [[ ! $branchName ]]; then
	# Exit if detached head
	branchName=$(git rev-parse --abbrev-ref HEAD)
	if [[ $branchName == HEAD ]]; then
		exit 2
	fi
elif [[ $branchName == "master" ]]; then
	
	# in the master branch, make sure the tag is clean ('1.2.3'; not 1.2.3-alpha) and there has been 0 commits since the tag has been set.
	if [[ $gitLongTag =~ [0-9]+.[0-9]+.[0-9]+-0-[0-9a-g]{8}$ ]]; then 

		releaseTag=$(echo $gitLongTag | sed -r "s/([0-9]+\.[0-9]+\.[0-9]+)-[0-9]+-.+/\1/")
		# since we are in the master branch and on a tag, we'll tag the images as "latest" too
		isLatest=true
	else

		echo "No tag found on the master branch -> will be tagged as 'master' and will not be tagges as 'latest'."
		releaseTag=$branchName
	fi

else

	lastTag=$(git describe --abbrev=0)
	commitCountSinceLastTag=$(git rev-list $lastTag.. --count)
	if [[ $commitCountSinceLastTag == 0 ]]; then
		releaseTag=$lastTag
	else
		releaseTag=$branchName
	fi

fi

if [[ $action == "build" ]]; then

	docker build -t osimis/orthanc-runner-base:current docker/orthanc-runner-base/
	docker build -t osimis/orthanc-builder-base:current docker/orthanc-builder-base/

	# in order to build other plugins like the MSSQL plugin, we need the orthanc-builder image
	# so we publish here.  Note that the tag here is not related to the tag of the osimis/orthanc images
	docker tag osimis/orthanc-builder-base:current osimis/orthanc-builder-base:20.4.0

  docker build -t osimis/orthanc:current -f docker/orthanc/Dockerfile docker/orthanc/
  docker build -t osimis/orthanc-pro:current -f docker/orthanc-pro-builder/Dockerfile docker/orthanc-pro-builder/

  docker tag osimis/orthanc:current osimis/orthanc:$releaseTag
  docker tag osimis/orthanc-pro:current osimis/orthanc-pro:$releaseTag
fi

if [[ $action == "pushToPublicRepo" ]]; then
  docker push osimis/orthanc-builder-base:20.4.0
  docker push osimis/orthanc:$releaseTag
  docker push osimis/orthanc-pro:$releaseTag

	if [[ $isLatest ]]; then
		docker tag osimis/orthanc:current osimis/orthanc:latest
		docker tag osimis/orthanc-pro:current osimis/orthanc-pro:latest

		docker push osimis/orthanc:latest
	fi

fi

if [[ $action == "pushToPrivateRepo" ]]; then
  docker tag osimis/orthanc-pro:current osimis.azurecr.io/orthanc-pro:$releaseTag
  docker push osimis.azurecr.io/orthanc-pro:$releaseTag
fi


