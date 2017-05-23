FROM ubuntu:16.04

RUN mkdir -p /etc/orthanc
RUN mkdir -p /usr/share/orthanc/plugins
RUN mkdir -p /usr/share/orthanc/config

# RUN apt-get update \ 
# && DEBIAN_FRONTEND=noninteractive apt-get -y install \
# libjsoncpp0 \
# libopenslide0 \
# libboost-filesystem1.58.0 \
# libboost-thread1.58.0 \
# libboost-regex1.58.0 \
# libboost-locale1.58.0 \
# libdcmtk2 \
# libcurl4-openssl-dev \
# liblua5.1-0 \
# libpugixml1 \
# libgdcm2.2 \
# libpq5 \
# && apt-get clean \
# && rm -rf /var/lib/apt/lists/*


COPY binaries/plugins/ /usr/share/orthanc/plugins
COPY binaries/executables/ /usr/bin

COPY orthanc/config/*.json /usr/share/orthanc/config/

RUN ln -s /usr/share/orthanc/config/remote-access.json /etc/orthanc/remote-access.json
RUN ln -s /usr/share/orthanc/config/plugins.json /etc/orthanc/plugins.json
RUN ln -s /usr/share/orthanc/config/storage.json /etc/orthanc/storage.json

ENTRYPOINT [ "Orthanc" ]
CMD [ "/etc/orthanc/" ]