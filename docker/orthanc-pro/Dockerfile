# CHANGE VERSION
FROM osimis/orthanc:17.6.1

RUN apt-get update \
&& DEBIAN_FRONTEND=noninteractive apt-get -y install \
curl \
apt-transport-https \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/*

COPY orthanc-pro/install-msodbcsql.sh /tmp/
RUN /tmp/install-msodbcsql.sh

# Necessary to avoid "locale::facet::_S_create_c_locale name not valid" error in isql connection test
#                and "hang without any message at SQLDriverConnect stage" in MSSQL-plugin UnitTests
RUN locale-gen "en_US.UTF-8"

COPY binaries/plugins-pro/ /usr/share/orthanc/plugins
RUN mv /usr/share/orthanc/plugins/libOsimisWebViewer.so /usr/share/orthanc/plugins-disabled/   # deactivate the basic webviewer

COPY orthanc-pro/config/*.json /usr/share/orthanc/config/
