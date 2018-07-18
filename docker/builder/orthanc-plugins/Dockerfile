FROM osimis/orthanc-builder:current
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
RUN ./build-webviewer.sh OrthancWebViewer-2.4 # CHANGE_VERSION

COPY build-postgresql.sh .
RUN ./build-postgresql.sh OrthancPostgreSQL-2.2 # mainline CHANGE_VERSION

COPY build-mysql.sh .
RUN ./build-mysql.sh OrthancMySQL-1.1 # mainline CHANGE_VERSION

COPY build-dicomweb.sh .
RUN ./build-dicomweb.sh OrthancDicomWeb-0.5 # mainline # CHANGE_VERSION

COPY build-wsi.sh .
RUN ./build-wsi.sh OrthancWSI-0.5 # CHANGE_VERSION

COPY build-authorization.sh .
RUN ./build-authorization.sh 0.2.1 # CHANGE_VERSION

COPY build-casablanca.sh .
RUN ./build-casablanca.sh 2.9.1 # CHANGE_VERSION

COPY build-azure-storage-cpp.sh .
RUN ./build-azure-storage-cpp.sh 3.0.0 # CHANGE_VERSION

COPY build-azure-storage-plugin.sh .
RUN ./build-azure-storage-plugin.sh 0.3.0 # CHANGE_VERSION
