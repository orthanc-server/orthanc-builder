FROM osimis/orthanc:17.5.alpha

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install curl apt-transport-https
# && DEBIAN_FRONTEND=noninteractive apt-get -y install \
# unixodbc
COPY orthanc-pro/install-msodbcsql.sh /tmp/

RUN /tmp/install-msodbcsql.sh

COPY binaries/plugins-pro/ /usr/share/orthanc/plugins

COPY orthanc-pro/config/*.json /usr/share/orthanc/config/

#TODO: remove before shipping !
COPY orthanc-pro/config/mssql-test-config.json /etc/orthanc/mssql-test-config.json