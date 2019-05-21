ARG BASE_ORTHANC_IMAGE_TAG=current

# CHANGE_VERSION_WSI_EXPERIMENTAL
FROM osimis/orthanc-wsi:experimental as wsix


FROM docker.io/osimis/orthanc:${BASE_ORTHANC_IMAGE_TAG}

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


# CHANGE_VERSION_WVP
RUN wget http://orthanc.osimis.io/lsb/plugin-osimis-webviewer-pro/releases/1.2.0.0/libOsimisWebViewerPro.so --output-document /usr/share/orthanc/plugins-disabled/libOsimisWebViewerPro.so --quiet

# CHANGE_VERSION_WVP_ALPHA
RUN wget http://orthanc.osimis.io/lsb/plugin-osimis-webviewer-pro/commits/d4b6c4b/libOsimisWebViewerPro.so --output-document /usr/share/orthanc/plugins-disabled/libOsimisWebViewerProAlpha.so --quiet

COPY --from=wsix /usr/share/orthanc/plugins/libOrthancWSI.so /tmp
RUN mv /tmp/libOrthancWSI.so /usr/share/orthanc/plugins-disabled/libOrthancWSIx.so


#CHANGE_VERSION_MSSQL
RUN wget orthanc.osimis.io/docker-so/mssql/1.0.0/libOrthancMsSqlIndex.so --output-document /usr/share/orthanc/plugins-disabled/libOrthancMsSqlIndex.so --quiet

#CHANGE_VERSION_BLOB_STORAGE
RUN wget orthanc.osimis.io/docker-so/blob-storage/0.3.2/libOrthancBlobStorage.so --output-document /usr/share/orthanc/plugins-disabled/libOrthancBlobStorage.so --quiet
RUN wget orthanc.osimis.io/docker-so/blob-storage/0.3.2/libazurestorage.so.3 --output-document /usr/local/lib/libazurestorage.so.3 --quiet
RUN wget orthanc.osimis.io/docker-so/blob-storage/0.3.2/libcpprest.so.2.9 --output-document /usr/local/lib/libcpprest.so.2.9 --quiet

# configure SSL for azure rest sdk
ENV SSL_CERT_DIR=/etc/ssl/certs