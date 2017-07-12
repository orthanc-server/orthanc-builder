FROM osimis/orthanc-builder
RUN apt-get update \
	&& DEBIAN_FRONTEND=noninteractive apt-get -y install \
		libgdcm2-dev \
		libjpeg-dev \
		postgresql-server-dev-all \
		libtiff-dev \
		libopenjpeg-dev \
		libopenslide-dev \
		libxml++2.6-dev \
		uuid-dev \
		git \
		python3-dev \
		python3-venv \
		python3-pip \
	&& rm -rf /var/lib/apt/lists/*

ARG BITBUCKET_USERINFO
WORKDIR /root

COPY build-webviewer.sh .
RUN ./build-webviewer.sh OrthancWebViewer-2.2 # CHANGE_VERSION

COPY build-postgresql.sh .
RUN ./build-postgresql.sh OrthancPostgreSQL-2.0 # CHANGE_VERSION

COPY build-dicomweb.sh .
RUN ./build-dicomweb.sh OrthancDicomWeb-0.3 # CHANGE_VERSION

COPY build-wsi.sh .
RUN ./build-wsi.sh OrthancWSI-0.4 # CHANGE_VERSION

COPY build-authorization.sh .
RUN ./build-authorization.sh 0.1.0 # CHANGE_VERSION

RUN git clone https://github.com/Microsoft/cpprestsdk.git casablanca
RUN git clone https://github.com/Azure/azure-storage-cpp.git azure-storage-cpp
RUN git clone "https://$BITBUCKET_USERINFO@bitbucket.org/osimis/orthanc-blob-storage.git"

COPY build-casablanca.sh .
RUN ./build-casablanca.sh

COPY build-azure-storage-cpp.sh .
RUN ./build-azure-storage-cpp.sh

COPY build-azure-storage-plugin.sh .
RUN ./build-azure-storage-plugin.sh 0.2.2 # CHANGE_VERSION
