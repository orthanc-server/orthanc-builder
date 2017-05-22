FROM ubuntu:14.04

RUN mkdir -p /etc/orthanc
RUN mkdir -p /usr/share/orthanc/plugins

RUN apt-get update \ 
&& DEBIAN_FRONTEND=noninteractive apt-get -y install \
libjsoncpp0 \
libopenslide0 \
libboost-filesystem1.54.0 \
libboost-thread1.54.0 \
libboost-regex1.54.0 \
libboost-locale1.54.0 \
libdcmtk2 \
libcurl4-openssl-dev \
liblua5.1-0 \
libpugixml1 \
libgdcm2.2 \
libpq5 \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/*


COPY binaries/plugins/ /usr/share/orthanc/plugins
COPY binaries/executables/ /usr/bin

COPY orthanc.json /etc/orthanc/
COPY osimis-webviewer.json /etc/orthanc/
COPY postgresql.json /etc/orthanc/
COPY serve-folders.json /etc/orthanc/
COPY worklists.json /etc/orthanc/

ENTRYPOINT [ "Orthanc" ]
CMD [ "/etc/orthanc/" ]