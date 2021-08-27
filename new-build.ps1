docker build -t osimis/orthanc-runner-base:current docker/orthanc-runner-base/
docker build -t osimis/orthanc-builder-base:current docker/orthanc-builder-base/
docker build -t osimis/orthanc:current -f docker/orthanc/Dockerfile docker/orthanc/
docker build --progress=plain -t osimis/orthanc-pro:current -f docker/orthanc-pro-builder/Dockerfile docker/orthanc-pro-builder/