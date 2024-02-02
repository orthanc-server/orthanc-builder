######################################
ARG IMAGE_TAG=latest
FROM orthancteam/orthanc:$IMAGE_TAG

RUN apt-get update
RUN	DEBIAN_FRONTEND=noninteractive apt-get --assume-yes install dcmtk mercurial
RUN pip install httplib2 --break-system-package
RUN pip install pillow --break-system-package

WORKDIR /

ARG ORTHANC_TESTS_REVISION=default
RUN hg clone https://orthanc.uclouvain.be/hg/orthanc-tests/ -r $ORTHANC_TESTS_REVISION

ENTRYPOINT python3 /orthanc-tests/Tests/CheckIngestTranscoding.py /usr/local/bin/Orthanc
