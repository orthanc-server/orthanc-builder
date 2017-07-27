FROM ubuntu:16.04
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install locales && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US
RUN locale-gen en_US.UTF-8
RUN update-locale 

ENTRYPOINT ["./docker-entrypoint"]
CMD ["/etc/orthanc"]
COPY orthanc/docker-entrypoint /

RUN mkdir -p /etc/orthanc /usr/lib/orthanc/setup.d

COPY binaries/plugins/ /usr/share/orthanc/plugins
COPY binaries/plugins-disabled/ /usr/share/orthanc/plugins-disabled
COPY binaries/executables/ /usr/bin

COPY orthanc/config/*.json /usr/share/orthanc/config/

RUN ln /usr/share/orthanc/config/remote-access.json /etc/orthanc/remote-access.json && \
    ln /usr/share/orthanc/config/plugins.json /etc/orthanc/plugins.json && \
    ln /usr/share/orthanc/config/storage.json /etc/orthanc/storage.json
