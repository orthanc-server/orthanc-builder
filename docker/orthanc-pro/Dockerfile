# CHANGE_VERSION
FROM osimis/orthanc:17.7.1

RUN apt-get update \
	DEBIAN_FRONTEND=noninteractive apt-get --assume-yes install \
		curl \
		apt-transport-https \
		libboost-log1.58.0 \
		libxml++2.6-2v5 \
	apt-get clean && \
	rm --recursive --force /var/lib/apt/lists/*

COPY orthanc-pro/install-msodbcsql.sh /tmp/
RUN /tmp/install-msodbcsql.sh

COPY orthanc-pro/setup.d/* /usr/lib/orthanc/setup.d/
COPY binaries/plugins-deps/ /usr/local/lib/
COPY binaries/plugins-pro/ /usr/share/orthanc/plugins-disabled/
