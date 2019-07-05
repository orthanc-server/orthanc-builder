#!/usr/bin/env bash
#
# builds osimis/orthanc and osimis/orthanc-pro images from CI
#
# usage:
# ciBuild.sh ${BRANCH_NAME}

set -o errexit
set -o xtrace

# make sure we use the latest ubuntu image (which is the base of everything we build)
docker pull ubuntu:18.04

# Retrieve git metadata
gitLongTag=$(git describe --long --dirty=-dirty)
branchName=${1:-$(git rev-parse --abbrev-ref HEAD)} #if no argument defined, get the branch name from git
releaseCommitId=$(git rev-parse --short HEAD)

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
		tagOptions="-t $releaseTag -l"
	else

		echo "No tag found on the master branch -> will be tagged as 'master' and will not be tagges as 'latest'."
		releaseTag=$branchName
		tagOptions="-t $releaseTag"
	fi

else
	lastTag=$(git describe --abbrev=0)
	commitCountSinceLastTag=$(git rev-list $lastTag.. --count)
	if [[ $commitCountSinceLastTag == 0 ]]; then
		releaseTag=$lastTag
	else
		releaseTag=$branchName
	fi

	tagOptions="-t $releaseTag"
fi

./build.sh $tagOptions -r
