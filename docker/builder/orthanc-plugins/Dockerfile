FROM osimis/orthanc-only
LABEL Description="Official plugins for Orthanc"
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install libgdcm2-dev libjpeg-dev postgresql-server-dev-all libtiff-dev libopenjpeg-dev libopenslide-dev && rm -rf /var/lib/apt/lists/*

COPY build-webviewer.sh /root/build-webviewer.sh
RUN /root/build-webviewer.sh "OrthancWebViewer-2.2" # CHANGE_VERSION

COPY build-postgresql.sh /root/build-postgresql.sh
RUN /root/build-postgresql.sh "OrthancPostgreSQL-2.0" # CHANGE_VERSION

COPY build-dicomweb.sh /root/build-dicomweb.sh
RUN /root/build-dicomweb.sh "OrthancDicomWeb-0.3" # CHANGE_VERSION

COPY build-wsi.sh /root/build-wsi.sh
RUN /root/build-wsi.sh "OrthancWSI-0.4" # CHANGE_VERSION

COPY build-authorization.sh /root/build-authorization.sh
RUN /root/build-authorization.sh "0.1.0"     # CHANGE_VERSION
