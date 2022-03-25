set -o errexit
set -o xtrace

docker build --progress=plain -t osimis/orthanc:current -f docker/orthanc/Dockerfile docker/orthanc/
