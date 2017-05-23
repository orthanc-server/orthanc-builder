FROM ubuntu:16.04

RUN mkdir -p /etc/orthanc
RUN mkdir -p /usr/share/orthanc/plugins
RUN mkdir -p /usr/share/orthanc/config

COPY binaries/plugins/ /usr/share/orthanc/plugins
COPY binaries/executables/ /usr/bin

COPY orthanc/config/*.json /usr/share/orthanc/config/

RUN ln -s /usr/share/orthanc/config/remote-access.json /etc/orthanc/remote-access.json
RUN ln -s /usr/share/orthanc/config/plugins.json /etc/orthanc/plugins.json
RUN ln -s /usr/share/orthanc/config/storage.json /etc/orthanc/storage.json

ENTRYPOINT [ "Orthanc" ]
CMD [ "/etc/orthanc/" ]