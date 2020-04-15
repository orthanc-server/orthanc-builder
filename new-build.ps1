docker build -t osimis/orthanc-runner-base:current docker/orthanc-runner-base/
docker build -t osimis/orthanc-builder-base:current docker/orthanc-builder-base/
# docker build -t osimis/orthanc-new:current -f docker/orthanc-builder-all/Dockerfile docker/
docker build -t osimis/orthanc -f docker/orthanc-builder-all/Dockerfile docker/