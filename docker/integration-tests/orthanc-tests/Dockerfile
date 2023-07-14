# mercurial does not work anymore on jodogne/orthanc-tests -> use a specific image
FROM ubuntu:22.04 as ubuntu-hg

RUN apt-get update
RUN	DEBIAN_FRONTEND=noninteractive apt-get --assume-yes install mercurial

WORKDIR /

ARG ORTHANC_TESTS_REVISION=default
RUN hg clone https://hg.orthanc-server.com/orthanc-tests/ -r $ORTHANC_TESTS_REVISION

##############################################################
FROM jodogne/orthanc-tests as orthanc-tests
RUN mkdir /tests
WORKDIR /tests

COPY --from=ubuntu-hg /orthanc-tests /tests/orthanc-tests
RUN ls -al /tests/
RUN mkdir /tmp/orthanc-tests/

RUN mkdir /scripts
COPY wait-for-it.sh /scripts

ENTRYPOINT /scripts/wait-for-it.sh orthanc-under-tests:8042 -t 60 && python /tests/orthanc-tests/Tests/Run.py --server=orthanc-under-tests --force --docker -- -v

##############################################################
FROM python:2.7 as python2-7-base-image

RUN apt-get update
RUN	DEBIAN_FRONTEND=noninteractive apt-get --assume-yes install dcmtk

RUN pip install easywebdav
RUN pip install httplib2
RUN pip install pillow
RUN pip install pydicom==1.4.1
RUN pip install pynetdicom==1.5.6

RUN mkdir /tests
WORKDIR /tests

COPY --from=ubuntu-hg /orthanc-tests /tests/orthanc-tests
RUN ls -al /tests/
RUN mkdir /tmp/orthanc-tests/

RUN mkdir /scripts
COPY wait-for-it.sh /scripts


##############################################################
FROM python:3.10 as python3-base-image

RUN apt-get update
RUN	DEBIAN_FRONTEND=noninteractive apt-get --assume-yes install dcmtk

RUN pip install httplib2
RUN pip install pillow
RUN pip install pydicom
RUN pip install pynetdicom

RUN mkdir /tests
WORKDIR /tests

COPY --from=ubuntu-hg /orthanc-tests /tests/orthanc-tests
RUN ls -al /tests/
RUN mkdir /tmp/orthanc-tests/

RUN mkdir /scripts
COPY wait-for-it.sh /scripts

##############################################################
FROM python3-base-image as orthanc-tests-dicomweb

ENTRYPOINT /scripts/wait-for-it.sh orthanc-under-tests:8042 -t 60 && python /tests/orthanc-tests/Plugins/DicomWeb/Run.py --server=orthanc-under-tests --force -- -v

##############################################################
FROM orthanc-tests as orthanc-tests-worklists

ENTRYPOINT /scripts/wait-for-it.sh orthanc-under-tests:8042 -t 60 && python /tests/orthanc-tests/Plugins/Worklists/Run.py --server=orthanc-under-tests -- -v

##############################################################
FROM orthanc-tests as orthanc-tests-recycling

ENTRYPOINT /scripts/wait-for-it.sh orthanc-under-tests:8042 -t 60 && python /tests/orthanc-tests/Plugins/Recycling/Run.py --server=orthanc-under-tests --force -- -v

##############################################################
FROM orthanc-tests as orthanc-tests-transfers

ENTRYPOINT /scripts/wait-for-it.sh orthanc-under-tests:8042 -t 60 && python /tests/orthanc-tests/Plugins/Transfers/Run.py --server=orthanc-under-tests --force -- -v

##############################################################
FROM python3-base-image as orthanc-tests-wsi

RUN apt-get update
RUN	DEBIAN_FRONTEND=noninteractive apt-get install -y libtiff-tools

RUN mkdir /apps

RUN wget https://orthanc.osimis.io/lsb/whole-slide-imaging/releases/2.0/OrthancWSIDicomToTiff --output-document /apps/OrthancWSIDicomToTiff --quiet
RUN wget https://orthanc.osimis.io/lsb/whole-slide-imaging/releases/2.0/OrthancWSIDicomizer --output-document /apps/OrthancWSIDicomizer --quiet

RUN chmod +x /apps/*

ENTRYPOINT /scripts/wait-for-it.sh orthanc-under-tests:8042 -t 60 && python /tests/orthanc-tests/Plugins/WSI/Run.py --server=orthanc-under-tests --force --dicomizer=/apps/OrthancWSIDicomizer --to-tiff=/apps/OrthancWSIDicomToTiff -- -v

##############################################################
FROM python2-7-base-image as orthanc-tests-webdav

ENTRYPOINT /scripts/wait-for-it.sh orthanc-under-tests:8042 -t 60 && python /tests/orthanc-tests/Plugins/WebDav/Run.py --server=orthanc-under-tests --force -- -v

##############################################################
FROM python2-7-base-image as orthanc-tests-cget

ENTRYPOINT /scripts/wait-for-it.sh orthanc-under-tests:8042 -t 60 && python /tests/orthanc-tests/Plugins/CGet/Run.py --server=orthanc-under-tests --force -- -v