#!/usr/bin/env bash
#
# build Docker images and eventually pushes them to DockerHub
# example usage:
# ./build.sh 17.10.1 true true

function usage {
	cat <<-EOF 1>&2
	Usage: $(basename "$0") [OPTIONS...] [VERSION [LATEST [PUSH]]]

	By default, all images are built and tagged with a random ID.
	Use -n combined with other switches to only build specific
	images.

	 -n             Don't build all images
	 -b             Build builder image
	 -o             Build osimis/orthanc image
	 -p             Build osimis/orthanc-pro image
	 -t             Version
	 -l             Tag the build as latest
	 -u             Don't use unique tags
	 -r             Push to registry
	 -h             Display help
	EOF
}

set -o errexit

runBuilder=true
buildImage=true
buildProImage=true
tag=$(LC_CTYPE=POSIX \
	tr --complement --delete '[:lower:][:digit:]' </dev/urandom \
	| head --bytes=12)
version=$tag

while getopts "nbopt:lurh" opt; do
	case "$opt" in
	n) unset runBuilder buildImage buildProImage;;
	b) runBuilder=true;;
	o) buildImage=true;;
	p) buildProImage=true;;
	t) version=$OPTARG;;
	l) tagLatest=true;;
	u) noUnique=true;;
	r) push=true;;
	h) usage; exit 0;;
	?) usage; exit 1;;
	esac
done
shift $((OPTIND-1))
set -o xtrace
args=(version tagLatest push)
while [[ ${args[0]} && $1 ]]; do
	eval "${args[0]}=$1"
	shift
	args=("${args[@]:1}")
done

if [[ $noUnique ]]; then
	tag=$version
fi

function build {
	local proc=$1 image=$2
	"./ciBuild$proc.sh" -t "$tag"
	docker tag "$image:$tag" "$image:$version"
	if [[ $push ]]; then
		docker push "$image:$version"
	fi
	if [[ $tagLatest ]]; then
		docker tag "$image:$tag" "$image:latest"
		if [[ $push ]]; then
			docker push "$image:latest"
		fi
	fi
}

if [[ $runBuilder ]]; then
	./ciBuildOrthancBuilderImage.sh -t "$tag"
fi
if [[ $buildImage ]]; then
	build OsimisOrthancDockerImage osimis/orthanc
fi
if [[ $buildProImage ]]; then
	build OsimisOrthancProDockerImage osimis/orthanc-pro
fi
