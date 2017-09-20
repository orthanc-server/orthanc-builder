# CHANGE_VERSION
FROM osimis/orthanc:17.8.0-alpha

RUN export DEBIAN_FRONTEND=noninteractive && \
	apt-get --assume-yes update && \
	apt-get --assume-yes install \
		curl \
		apt-transport-https && \
	curl https://packages.microsoft.com/keys/microsoft.asc \
		| apt-key add - && \
	curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list \
		> /etc/apt/sources.list.d/mssql-release.list && \
	apt-get --assume-yes update && \
	ACCEPT_EULA=Y apt-get --assume-yes install \
		libboost-log1.58.0 \
		libxml++2.6-2v5 \
		msodbcsql=13.1.4.0-1 && \
	apt-get --assume-yes remove --purge --auto-remove curl apt-transport-https && \
	apt-get --assume-yes clean && \
	rm --recursive --force /var/lib/apt/lists/* /etc/apt/sources.list.d/mssql-release.list

COPY orthanc-pro/setup.d/* /usr/lib/orthanc/setup.d/
COPY binaries/plugins-deps/ /usr/local/lib/
COPY binaries/plugins-pro/ /usr/share/orthanc/plugins-disabled/
