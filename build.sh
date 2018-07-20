#!/usr/bin/env bash
#
# to build osimis/orthanc(and -pro):17.11.2 and tag it as latest and push
# them to DockerHub
# ./build.sh -t 17.11.2 -r -l
#
# to build an osimis/orthanc image with the orthanc mainline:
# change the ORTHANC_VERSION in ciBuildOrthancBuilderImage.sh 
# (use a commit id and not 'default' or docker might reuse its cache)
# then call:
# ./build.sh -t 17.11.2-orthanc-mainline-20171125 -r
#
# build osimis/orthanc with latest tag, no unique tag/version, without
# building the rest (useful when iterating on setup samples):
# ./build.sh -nolu
#

function usage {
	cat <<-EOF 1>&2
	Usage: $(basename "$0") [OPTIONS...] [VERSION]

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

while getopts "nopt:lurh" opt; do
	case "$opt" in
	n) unset runBuilder buildImage buildProImage;;
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
set -o xtrace

if [[ $noUnique ]]; then
	if [[ $version ]]; then
		tag=$version
	elif [[ $tagLatest ]]; then
		tag=latest
	else
		cat <<-EOF >&2
		ERROR: No usable tag

		Need to at least:
		- Allow unique tags or,
		- Specify a version or,
		- Tag as latest.
		EOF
		exit 2
	fi
fi

function build {
	local proc=$1 image=docker.io/$2
	"./ciBuild$proc.sh" -t "$tag"
	docker tag "$image:$tag" "$image:current"
	if [[ $version ]]; then
		docker tag "$image:$tag" "$image:$version"
		if [[ $push ]]; then
			docker push "$image:$version"
		fi
	fi
	if [[ $tagLatest ]]; then
		docker tag "$image:$tag" "$image:latest"
		if [[ $push ]]; then
			docker push "$image:latest"
		fi
	fi
}

if [[ $buildImage ]]; then
	build OsimisOrthancDockerImage osimis/orthanc
fi
if [[ $buildProImage ]]; then
	build OsimisOrthancProDockerImage osimis/orthanc-pro
fi
