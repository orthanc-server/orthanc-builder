#!/bin/bash
# builds the Orthanc images (based on https://github.com/jodogne/OrthancDocker)

set -x #to debug the script
set -e #to exit the script at the first failure

cd "${REPOSITORY_PATH:-$(git rev-parse --show-toplevel)}/docker/builder"

if [[ ! $BITBUCKET_USERINFO ]]; then
	cat <<-EOF >&2
	Please set the BITBUCKET_USERINFO environment variable to valid
	credentials as 'username:password'.  It is recommended to use
	restricted "App passwords" instead of the main account
	password. Only repository read access is required.
	EOF
	exit 1
fi

# build the base image (ubuntu + build tools)
docker build --tag=osimis/orthanc-builder-base:current base "$@"

# build the orthanc-builder image (no plugin)
docker build --tag=osimis/orthanc-builder:current \
	--build-arg=ORTHANC_VERSION=jobs \
	orthanc "$@"
# CHANGE_VERSION (official version is someting like Orthanc-1.3.0)

# build the orthanc-builder-plugins image
docker build --tag=osimis/orthanc-builder-plugins:current \
	"--build-arg=BITBUCKET_USERINFO=$BITBUCKET_USERINFO" \
	orthanc-plugins "$@"

# at this stage, you may build the osimis/orthanc image by picking all the required .so files from the latest image 
