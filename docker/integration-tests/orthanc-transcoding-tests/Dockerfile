######################################
ARG IMAGE_TAG=latest
FROM osimis/orthanc:$IMAGE_TAG

RUN apt-get update
RUN	DEBIAN_FRONTEND=noninteractive apt-get --assume-yes install dcmtk mercurial
RUN pip install httplib2
RUN pip install pillow

WORKDIR /

ARG ORTHANC_TESTS_REVISION=default
RUN hg clone https://hg.orthanc-server.com/orthanc-tests/ -r $ORTHANC_TESTS_REVISION

ENTRYPOINT python3 /orthanc-tests/Tests/CheckIngestTranscoding.py /usr/local/bin/Orthanc
