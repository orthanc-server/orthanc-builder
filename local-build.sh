set -o errexit
set -o xtrace

docker build --progress=plain -t osimis/orthanc-runner-base:current -f docker/orthanc/Dockerfile.runner-base docker/orthanc

docker build --progress=plain -t osimis/orthanc-builder-base:current --build-arg BASE_IMAGE_TAG=current -f docker/orthanc/Dockerfile.builder-base docker/orthanc

docker build --progress=plain -t osimis/orthanc-builder-base:vcpkg-current --build-arg BASE_IMAGE_TAG=current -f docker/orthanc/Dockerfile.builder-vcpkg --target orthanc-build-vcpkg docker/orthanc
docker build --progress=plain -t osimis/orthanc-builder-base:vcpkg-google-current --build-arg BASE_IMAGE_TAG=current -f docker/orthanc/Dockerfile.builder-vcpkg --target orthanc-build-vcpkg-google docker/orthanc
docker build --progress=plain -t osimis/orthanc-builder-base:vcpkg-azure-current --build-arg BASE_IMAGE_TAG=current -f docker/orthanc/Dockerfile.builder-vcpkg --target orthanc-build-vcpkg-azure docker/orthanc

docker build --progress=plain -t osimis/orthanc:current --build-arg BASE_IMAGE_TAG=current -f docker/orthanc/Dockerfile docker/orthanc/
