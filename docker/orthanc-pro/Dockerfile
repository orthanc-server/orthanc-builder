FROM osimis/orthanc:17.5.beta

RUN apt-get update \
&& DEBIAN_FRONTEND=noninteractive apt-get -y install \
curl \
apt-transport-https \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/*

COPY orthanc-pro/install-msodbcsql.sh /tmp/
RUN /tmp/install-msodbcsql.sh

COPY binaries/plugins-pro/ /usr/share/orthanc/plugins
RUN mv /usr/share/orthanc/plugins/libOsimisWebViewer.so /usr/share/orthanc/plugins-disabled/   # deactivate the basic webviewer

COPY orthanc-pro/config/*.json /usr/share/orthanc/config/
