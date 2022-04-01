set -o errexit
set -o xtrace

version=${1:-stable}
platform=${2:-linux/amd64}

# get version number from build-matrix.json (stable or unstable)
# note: we get the last commit id from a branch to detect last changes in a branch

getCommitId() { # $1 = name, $2 = version (stable or unstable)
    revision=$(cat build-matrix.json | jq -r ".configs[] | select( .name == \"$1\").$2")
    repo=$(cat build-matrix.json | jq -r ".configs[] | select( .name == \"$1\").repo")
    commit_id=$(hg identify $repo -r $revision)
    echo $commit_id
}

ORTHANC_COMMIT_ID=$(getCommitId "Orthanc" $version)
ORTHANC_GDCM_COMMIT_ID=$(getCommitId "Orthanc-gdcm" $version)

# docker build --progress=plain --platform=$platform -t osimis/orthanc-runner-base:current -f docker/orthanc/Dockerfile.runner-base docker/orthanc

# docker build --progress=plain --platform=$platform -t osimis/orthanc-builder-base:current --build-arg BASE_IMAGE_TAG=current -f docker/orthanc/Dockerfile.builder-base docker/orthanc

# docker build --progress=plain --platform=$platform -t osimis/orthanc-builder-base:vcpkg-current --build-arg BASE_IMAGE_TAG=current -f docker/orthanc/Dockerfile.builder-vcpkg --target orthanc-build-vcpkg docker/orthanc
# docker build --progress=plain --platform=$platform -t osimis/orthanc-builder-base:vcpkg-google-current --build-arg BASE_IMAGE_TAG=current -f docker/orthanc/Dockerfile.builder-vcpkg --target orthanc-build-vcpkg-google docker/orthanc
# docker build --progress=plain --platform=$platform -t osimis/orthanc-builder-base:vcpkg-azure-current --build-arg BASE_IMAGE_TAG=current -f docker/orthanc/Dockerfile.builder-vcpkg --target orthanc-build-vcpkg-azure docker/orthanc

docker build \
  --progress=plain --platform=$platform -t osimis/orthanc:current --build-arg BASE_IMAGE_TAG=current \
  --build-arg ORTHANC_COMMIT_ID=$ORTHANC_COMMIT_ID \
  --build-arg ORTHANC_GDCM_COMMIT_ID=$ORTHANC_GDCM_COMMIT_ID \
  -f docker/orthanc/Dockerfile  docker/orthanc/
