#!/usr/bin/env bash
#
# builds osimis/orthanc and osimis/orthanc-pro images from CI
#
# usage:
# ciBuild.sh ${BRANCH_NAME}

set -o errexit
set -o xtrace

# make sure we use the latest ubuntu image (which is the base of everything we build)
docker pull ubuntu:16.04

# Retrieve git metadata
gitLongTag=$(git describe --long --dirty)
branchName=${1:-$(git rev-parse --abbrev-ref HEAD)} #if no argument defined, get the branch name from git
releaseCommitId=$(git rev-parse --short HEAD)

viewerVersion=$(git describe --tags --long --dirty=-dirty) # version as used in cmake for backend build

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
	else

		echo "Invalid tag on the master branch.  Make sure you have just tagged the master branch with something like '17.11.3' and that there has been no commit after the tag."
		exit -1	
	fi

	# since we are in the master branch, we'll tag the images as "latest" too
	tagOptions="-t $releaseTag -l"
else
	# in other branches than master, the versionNumber is the branchName
	releaseTag=$branchName
	
	# if the branch name is something like 'am/WVB-27', the image tag should be 'am-WVB-27'
	# replace / by -
	releaseTag=${releaseTag//\//-}

	tagOptions="-t $releaseTag"
fi

./build.sh $tagOptions -r
