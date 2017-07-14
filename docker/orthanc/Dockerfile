FROM ubuntu:16.04
ENTRYPOINT ["./docker-entrypoint"]
CMD ["/etc/orthanc"]
COPY orthanc/docker-entrypoint /

RUN mkdir -p /etc/orthanc /usr/lib/orthanc/setup.d

COPY binaries/plugins/ /usr/share/orthanc/plugins
COPY binaries/plugins-disabled/ /usr/share/orthanc/plugins-disabled
COPY binaries/executables/ /usr/bin

COPY orthanc/config/*.json /usr/share/orthanc/config/

RUN ln -s /usr/share/orthanc/config/remote-access.json /etc/orthanc/remote-access.json && \
    ln -s /usr/share/orthanc/config/plugins.json /etc/orthanc/plugins.json && \
    ln -s /usr/share/orthanc/config/storage.json /etc/orthanc/storage.json
