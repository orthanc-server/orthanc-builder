FROM osimis/orthanc-only
LABEL Description="Official plugins for Orthanc" Vendor="Sebastien Jodogne, University Hospital of Liege"
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install libgdcm2-dev libjpeg-dev postgresql-server-dev-all libtiff-dev libopenjpeg-dev libopenslide-dev && rm -rf /var/lib/apt/lists/*

ADD ./build-webviewer.sh /root/build-webviewer.sh
RUN bash /root/build-webviewer.sh "OrthancWebViewer-2.2" # CHANGE_VERSION

ADD ./build-postgresql.sh /root/build-postgresql.sh
RUN bash /root/build-postgresql.sh "OrthancPostgreSQL-2.0" # CHANGE_VERSION

ADD ./build-dicomweb.sh /root/build-dicomweb.sh
RUN bash /root/build-dicomweb.sh "OrthancDicomWeb-0.3" # CHANGE_VERSION

ADD ./build-wsi.sh /root/build-wsi.sh
RUN bash /root/build-wsi.sh "OrthancWSI-0.4" # CHANGE_VERSION

ADD ./build-authorization.sh /root/build-authorization.sh
RUN bash /root/build-authorization.sh "0.1.0"     # CHANGE_VERSION

ENTRYPOINT [ "Orthanc" ]
CMD [ "/etc/orthanc/" ]
