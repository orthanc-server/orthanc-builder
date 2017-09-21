FROM ubuntu:16.04
SHELL ["/bin/bash", "-c"]
ENTRYPOINT ["/docker-entrypoint"]
CMD ["/etc/orthanc", "--unlock"]

RUN export DEBIAN_FRONTEND=noninteractive && \
	apt-get --assume-yes update && \
	apt-get --assume-yes install locales && \
	apt-get --assume-yes clean && \
	rm --recursive --force /var/lib/apt/lists/* && \
	locale-gen en_US en_US.UTF-8

RUN mkdir --parents \
	/etc/orthanc \
	/usr/lib/orthanc/setup.d \
	/usr/share/orthanc/plugins

COPY orthanc/docker-entrypoint /
COPY orthanc/setup.sh /usr/lib/orthanc/
COPY orthanc/setup.d/* /usr/lib/orthanc/setup.d/
COPY binaries/plugins/ /usr/share/orthanc/plugins-disabled
COPY binaries/executables/ /usr/bin
