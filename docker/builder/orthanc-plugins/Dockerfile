FROM osimis/orthanc-builder
RUN apt-get update \
	&& DEBIAN_FRONTEND=noninteractive apt-get -y install \
		libgdcm2-dev \
		libjpeg-dev \
		postgresql-server-dev-all \
		libtiff-dev \
		libopenjpeg-dev \
		libopenslide-dev \
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
