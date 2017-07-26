# CHANGE_VERSION
FROM osimis/orthanc:17.7.0

RUN apt-get update \
&& DEBIAN_FRONTEND=noninteractive apt-get -y install \
	curl \
	apt-transport-https \
	locales \
	libboost-log1.58.0 \
	libxml++2.6-2v5 \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/*

COPY orthanc-pro/install-msodbcsql.sh /tmp/
RUN /tmp/install-msodbcsql.sh

# Necessary to avoid "locale::facet::_S_create_c_locale name not valid" error in isql connection test
#                and "hang without any message at SQLDriverConnect stage" in MSSQL-plugin UnitTests
RUN locale-gen en_US
RUN locale-gen en_US.UTF-8
RUN update-locale

COPY orthanc-pro/setup.d/* /usr/lib/orthanc/setup.d/

COPY binaries/plugins-deps/ /usr/local/lib/
COPY binaries/plugins-pro/ /usr/share/orthanc/plugins-disabled/
RUN mv /usr/share/orthanc/plugins/libOsimisWebViewer.so /usr/share/orthanc/plugins-disabled/   # deactivate the basic webviewer

COPY orthanc-pro/config/*.json /usr/share/orthanc/config/
