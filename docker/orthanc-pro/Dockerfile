ARG BASE_ORTHANC_IMAGE_TAG=current

FROM docker.io/osimis/orthanc:${BASE_ORTHANC_IMAGE_TAG}

RUN export DEBIAN_FRONTEND=noninteractive && \
	apt-get --assume-yes update && \
		apt-get --assume-yes install gnupg2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list
RUN apt-get update && \
  ACCEPT_EULA=Y apt-get install -y msodbcsql17 unixodbc-dev && \
  DEBIAN_FRONTEND=noninteractive apt-get -y install libcpprest && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# CHANGE_VERSION_WVP
RUN wget http://orthanc.osimis.io/lsb/plugin-osimis-webviewer-pro/releases/1.3.1.0/libOsimisWebViewerPro.so --output-document /usr/share/orthanc/plugins-disabled/libOsimisWebViewerPro.so --quiet

# CHANGE_VERSION_WVP_ALPHA
RUN wget http://orthanc.osimis.io/lsb/plugin-osimis-webviewer-pro/commits/68fa1f85/libOsimisWebViewerPro.so --output-document /usr/share/orthanc/plugins-disabled/libOsimisWebViewerProAlpha.so --quiet

#CHANGE_VERSION_MSSQL
RUN wget orthanc.osimis.io/docker-so/mssql/debian-buster/dyn-build/libOrthancMsSqlIndex.so --output-document /usr/share/orthanc/plugins-disabled/libOrthancMsSqlIndex.so --quiet

#CHANGE_VERSION_BLOB_STORAGE
RUN wget orthanc.osimis.io/docker-so/blob-storage/debian-buster/dyn-build/libOrthancBlobStorage.so --output-document /usr/share/orthanc/plugins-disabled/libOrthancBlobStorage.so --quiet
RUN wget orthanc.osimis.io/docker-so/blob-storage/debian-buster/dyn-build/libazurestorage.so.7 --output-document /usr/lib/x86_64-linux-gnu/libazurestorage.so.7 --quiet

# configure SSL for azure rest sdk
ENV SSL_CERT_DIR=/etc/ssl/certs

COPY orthanc-pro/*.json /startup/ 
