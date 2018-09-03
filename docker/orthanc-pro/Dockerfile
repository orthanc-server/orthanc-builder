# CHANGE_VERSION_WVP
FROM osimis/osimis-webviewer-pro:1.1.1.0 as wvp

# CHANGE_VERSION_WVP_ALPHA
FROM osimis/osimis-webviewer-pro:9c6b4d3 as wvp-alpha

# CHANGE_VERSION_WSI_EXPERIMENTAL
FROM osimis/orthanc-wsi:experimental as wsix



FROM docker.io/osimis/orthanc:current

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

COPY --from=wvp-alpha /usr/share/orthanc/plugins/libOsimisWebViewerPro.so /usr/share/orthanc/plugins-disabled/
RUN mv /usr/share/orthanc/plugins-disabled/libOsimisWebViewerPro.so /usr/share/orthanc/plugins-disabled/libOsimisWebViewerProAlpha.so
COPY --from=wvp /usr/share/orthanc/plugins/libOsimisWebViewerPro.so /usr/share/orthanc/plugins-disabled/

COPY --from=wsix /usr/share/orthanc/plugins/libOrthancWSI.so /tmp
RUN mv /tmp/libOrthancWSI.so /usr/share/orthanc/plugins-disabled/libOrthancWSIx.so


#CHANGE_VERSION_MSSQL
RUN wget orthanc.osimis.io/docker-so/mssql/1.0.0/libOrthancMsSqlIndex.so --output-document /usr/share/orthanc/plugins-disabled/libOrthancMsSqlIndex.so --quiet

#CHANGE_VERSION_BLOB_STORAGE
RUN wget orthanc.osimis.io/docker-so/blob-storage/0.3.0/libOrthancBlobStorage.so --output-document /usr/share/orthanc/plugins-disabled/libOrthancBlobStorage.so --quiet
RUN wget orthanc.osimis.io/docker-so/blob-storage/0.3.0/libazurestorage.so.3 --output-document /usr/local/lib/libazurestorage.so.3 --quiet
RUN wget orthanc.osimis.io/docker-so/blob-storage/0.3.0/libcpprest.so.2.9 --output-document /usr/local/lib/libcpprest.so.2.9 --quiet

