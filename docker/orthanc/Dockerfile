FROM ubuntu:16.04
SHELL ["/bin/bash", "-c"]
ENTRYPOINT ["/docker-entrypoint"]
CMD ["/etc/orthanc"]

RUN export DEBIAN_FRONTEND=noninteractive && \
	apt-get --assume-yes update && \
	apt-get --assume-yes install locales && \
	apt-get --assume-yes clean && \
	rm --recursive --force /var/lib/apt/lists/* && \
	locale-gen en_US && \
	locale-gen en_US.UTF-8 && \
	update-locale

RUN mkdir --parents /etc/orthanc /usr/lib/orthanc/setup.d

COPY orthanc/docker-entrypoint /
COPY binaries/plugins/ /usr/share/orthanc/plugins
COPY binaries/plugins-disabled/ /usr/share/orthanc/plugins-disabled
COPY binaries/executables/ /usr/bin

COPY orthanc/config/*.json /usr/share/orthanc/config/
RUN ln /usr/share/orthanc/config/{remote-access,plugins,storage}.json /etc/orthanc/
