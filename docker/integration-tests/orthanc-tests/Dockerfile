# mercurial does not work anymore on jodogne/orthanc-tests -> use a specific image
FROM ubuntu:22.04 as ubuntu-hg

RUN apt-get update
RUN	DEBIAN_FRONTEND=noninteractive apt-get --assume-yes install mercurial

WORKDIR /

ARG ORTHANC_TESTS_REVISION=default
RUN hg clone https://orthanc.uclouvain.be/hg/orthanc-tests/ -r $ORTHANC_TESTS_REVISION

##############################################################
FROM jodogne/orthanc-tests AS orthanc-tests
RUN mkdir /tests
WORKDIR /tests

COPY --from=ubuntu-hg /orthanc-tests /tests/orthanc-tests
RUN ls -al /tests/
RUN mkdir /tmp/orthanc-tests/

RUN mkdir /scripts
COPY wait-for-it.sh /scripts

ENTRYPOINT /scripts/wait-for-it.sh orthanc-under-tests:8042 -t 60 && python /tests/orthanc-tests/Tests/Run.py --server=orthanc-under-tests --force --docker -- -v

##############################################################
FROM python:2.7 AS python2-7-base-image

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
FROM python:3.11 AS python3-base-image

RUN apt-get update
RUN	DEBIAN_FRONTEND=noninteractive apt-get --assume-yes install dcmtk

RUN pip install httplib2 --break-system-package
RUN pip install pillow --break-system-package
RUN pip install pydicom --break-system-package
RUN pip install pynetdicom --break-system-package
RUN pip install 'easywebdav @ git+https://github.com/Marpache9131/easywebdav@511967ec374061161f2b3b67fb7b164fcc78143c' --break-system-package

# remove echoscu... from pynetdicom to make sure we use the ones from DCMTK
RUN rm /usr/local/bin/findscu /usr/local/bin/storescu /usr/local/bin/echoscu /usr/local/bin/movescu /usr/local/bin/getscu

RUN mkdir /tests
WORKDIR /tests

COPY --from=ubuntu-hg /orthanc-tests /tests/orthanc-tests
RUN ls -al /tests/
RUN mkdir /tmp/orthanc-tests/

RUN mkdir /scripts
COPY wait-for-it.sh /scripts

##############################################################
FROM python3-base-image AS orthanc-tests-dicomweb

ENTRYPOINT /scripts/wait-for-it.sh orthanc-under-tests:8042 -t 60 && python /tests/orthanc-tests/Plugins/DicomWeb/Run.py --server=orthanc-under-tests --force -- -v

##############################################################
FROM orthanc-tests AS orthanc-tests-worklists

ENTRYPOINT /scripts/wait-for-it.sh orthanc-under-tests:8042 -t 60 && python /tests/orthanc-tests/Plugins/Worklists/Run.py --server=orthanc-under-tests -- -v

##############################################################
FROM orthanc-tests AS orthanc-tests-recycling

ENTRYPOINT /scripts/wait-for-it.sh orthanc-under-tests:8042 -t 60 && python /tests/orthanc-tests/Plugins/Recycling/Run.py --server=orthanc-under-tests --force -- -v

##############################################################
FROM orthanc-tests AS orthanc-tests-transfers

ENTRYPOINT /scripts/wait-for-it.sh orthanc-under-tests:8042 -t 60 && python /tests/orthanc-tests/Plugins/Transfers/Run.py --server=orthanc-under-tests --force -- -v

##############################################################
FROM python3-base-image AS orthanc-tests-wsi

RUN apt-get update
RUN	DEBIAN_FRONTEND=noninteractive apt-get install -y libtiff-tools

RUN mkdir /apps

RUN wget https://orthanc.uclouvain.be/downloads/linux-standard-base/orthanc-wsi/2.1/OrthancWSIDicomToTiff --output-document /apps/OrthancWSIDicomToTiff --quiet
RUN wget https://orthanc.uclouvain.be/downloads/linux-standard-base/orthanc-wsi/2.1/OrthancWSIDicomizer --output-document /apps/OrthancWSIDicomizer --quiet

RUN chmod +x /apps/*

ENTRYPOINT /scripts/wait-for-it.sh orthanc-under-tests:8042 -t 60 && python /tests/orthanc-tests/Plugins/WSI/Run.py --server=orthanc-under-tests --force --dicomizer=/apps/OrthancWSIDicomizer --to-tiff=/apps/OrthancWSIDicomToTiff -- -v

##############################################################
FROM python3-base-image AS orthanc-tests-webdav

ENTRYPOINT /scripts/wait-for-it.sh orthanc-under-tests:8042 -t 60 && python /tests/orthanc-tests/Plugins/WebDav/Run.py --server=orthanc-under-tests --force -- -v

##############################################################
FROM python3-base-image AS orthanc-tests-cget

ENTRYPOINT /scripts/wait-for-it.sh orthanc-under-tests:8042 -t 60 && python /tests/orthanc-tests/Plugins/CGet/Run.py --server=orthanc-under-tests --force -- -v

##############################################################
FROM python3-base-image AS orthanc-tests-tls-no-check-client-generate-config
WORKDIR /tls
ENTRYPOINT python /tests/orthanc-tests/Tests/CheckDicomTls.py --config-no-check-client

##############################################################
FROM python3-base-image AS orthanc-tests-tls-no-check-client
WORKDIR /tls
ENTRYPOINT /scripts/wait-for-it.sh orthanc-under-tests:8042 -t 60 && python /tests/orthanc-tests/Tests/CheckDicomTls.py --server=orthanc-under-tests --force -- -v OrthancNoCheckClient

##############################################################
FROM python3-base-image AS orthanc-tests-tls-check-client-generate-config
WORKDIR /tls
ENTRYPOINT python /tests/orthanc-tests/Tests/CheckDicomTls.py --config-check-client

##############################################################
FROM python3-base-image AS orthanc-tests-tls-check-client
WORKDIR /tls
ENTRYPOINT /scripts/wait-for-it.sh orthanc-under-tests:8042 -t 60 && python /tests/orthanc-tests/Tests/CheckDicomTls.py --server=orthanc-under-tests --force -- -v OrthancCheckClient
