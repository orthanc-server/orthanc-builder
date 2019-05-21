#!/usr/bin/env bash
set -o errexit
set -o xtrace

cd "${REPOSITORY_PATH:-$(git rev-parse --show-toplevel)}/docker"

while getopts "t:" opt; do
	case "$opt" in
	t) tag=$OPTARG;;
	?) exit 1;;
	esac
done
shift $((OPTIND-1))
if [[ ! $tag ]]; then
	tag=current
fi

# build the osimis/orthanc-pro image
docker build --build-arg BASE_ORTHANC_IMAGE_TAG=$tag "--tag=docker.io/osimis/orthanc-pro:$tag" --file=orthanc-pro/Dockerfile .
