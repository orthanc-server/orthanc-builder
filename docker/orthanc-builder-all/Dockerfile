########################## Orthanc

FROM osimis/orthanc-builder-base:current as build-orthanc

# CHANGE_VERSION_ORTHANC
RUN hg clone https://hg.orthanc-server.com/orthanc/ -r "Orthanc-1.6.0" /sources
WORKDIR /build
RUN cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DSTANDALONE_BUILD=ON -DUSE_GOOGLE_TEST_DEBIAN_PACKAGE=ON -DUSE_SYSTEM_CIVETWEB=OFF /sources
RUN make -j 4
RUN /build/UnitTests

########################## Orthanc PG

FROM osimis/orthanc-builder-base:current as build-plugin-pg

RUN apt-get --assume-yes update
RUN apt-get --assume-yes install libpq-dev postgresql-server-dev-all

# CHANGE_VERSION_PG
RUN hg clone https://hg.orthanc-server.com/orthanc-databases/ -r "OrthancPostgreSQL-3.2" /sources
WORKDIR /build
RUN cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF /sources/PostgreSQL
RUN make -j 4
# disabled: needs a PG server # RUN /build/UnitTests

########################## Orthanc MySQL

FROM osimis/orthanc-builder-base:current as build-plugin-mysql

RUN apt-get --assume-yes update
RUN apt-get --assume-yes install libmariadb-dev

# CHANGE_VERSION_MY_SQL
RUN hg clone https://hg.orthanc-server.com/orthanc-databases/ -r "OrthancMySQL-2.0" /sources
WORKDIR /build
RUN cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF /sources/MySQL
RUN make -j 4
# disabled: needs a MySQL server # RUN /build/UnitTests

########################## Orthanc Transfers

FROM osimis/orthanc-builder-base:current as build-plugin-transfers

# CHANGE_VERSION_TRANSFERS
RUN hg clone https://hg.orthanc-server.com/orthanc-transfers/ -r "OrthancTransfers-1.0" /sources
WORKDIR /build
RUN cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF /sources
RUN make -j 4
RUN /build/UnitTests

########################## Orthanc Dicomweb

FROM osimis/orthanc-builder-base:current as build-plugin-dicomweb

# CHANGE_VERSION_DW
RUN hg clone https://hg.orthanc-server.com/orthanc-dicomweb/ -r "OrthancDicomWeb-1.1" /sources
WORKDIR /build
RUN cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF -DUSE_SYSTEM_GDCM=OFF /sources
RUN make -j 4
RUN /build/UnitTests

########################## Orthanc WSI

FROM osimis/orthanc-builder-base:current as build-plugin-wsi

# CHANGE_VERSION_ORTHANC_WSI
RUN hg clone https://hg.orthanc-server.com/orthanc-wsi/ -r "OrthancWSI-0.6" /sources
WORKDIR /build
RUN cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF -DUSE_SYSTEM_OPENJPEG=OFF /sources/ViewerPlugin
RUN make -j 4
# disabled: no unit tests: # RUN /build/UnitTests

########################## Orthanc Webviewer

FROM osimis/orthanc-builder-base:current as build-plugin-owv

# CHANGE_VERSION_ORTHANC_WEB_VIEWER
RUN hg clone https://hg.orthanc-server.com/orthanc-webviewer/ -r "OrthancWebViewer-2.5" /sources
WORKDIR /build
RUN cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF -DUSE_SYSTEM_GDCM=OFF /sources
RUN make -j 4
RUN /build/UnitTests

########################## Orthanc authorization

FROM osimis/orthanc-builder-base:current as build-plugin-auth

# CHANGE_VERSION_AUTH
RUN hg clone https://hg.orthanc-server.com/orthanc-authorization/ -r "0.2.3" /sources
WORKDIR /build
RUN cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF /sources
RUN make -j 4
# disabled: no unit tests: # RUN /build/UnitTests

########################## Orthanc GCP

FROM osimis/orthanc-builder-base:current as build-plugin-gcp

# CHANGE_VERSION_GOOGLE
RUN hg clone https://hg.orthanc-server.com/orthanc-gcp/ -r "OrthancGoogleCloudPlatform-1.0" /sources
WORKDIR /build
RUN cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF /sources
RUN make -j 4
# disabled: no unit tests: # RUN /build/UnitTests

########################## Orthanc Python

FROM osimis/orthanc-builder-base:current as build-plugin-python

RUN apt-get --assume-yes update
RUN apt-get --assume-yes install python3.7-dev

# CHANGE_VERSION_ORTHANC_PYTHON
RUN hg clone https://hg.orthanc-server.com/orthanc-python/ -r "OrthancPython-1.0" /sources
WORKDIR /build
RUN cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF -DPYTHON_VERSION=3.7 /sources
RUN make -j 4
# disabled: no unit tests: # RUN /build/UnitTests

################################# the image that will run Orthanc dynamicaly linked
FROM osimis/orthanc-runner-base:current

RUN mkdir -p /etc/orthanc
RUN mkdir -p /usr/share/orthanc/plugins-disabled/
RUN mkdir -p /usr/share/orthanc/plugins/

COPY --from=build-orthanc /build/Orthanc /usr/local/bin/
COPY --from=build-orthanc /build/libModalityWorklists.so /usr/share/orhtanc/plugins-disabled/
COPY --from=build-orthanc /build/libServeFolders.so /usr/share/orhtanc/plugins-disabled/
COPY --from=build-orthanc /build/libConnectivityChecks.so /usr/share/orhtanc/plugins-disabled/
# RUN ldd /usr/bin/Orthanc

COPY --from=build-plugin-pg /build/libOrthancPostgreSQLIndex.so /usr/share/orhtanc/plugins-disabled/
COPY --from=build-plugin-pg /build/libOrthancPostgreSQLStorage.so /usr/share/orhtanc/plugins-disabled/
COPY --from=build-plugin-mysql /build/libOrthancMySQLIndex.so /usr/share/orhtanc/plugins-disabled/
COPY --from=build-plugin-mysql /build/libOrthancMySQLStorage.so /usr/share/orhtanc/plugins-disabled/
COPY --from=build-plugin-transfers /build/libOrthancTransfers.so /usr/share/orhtanc/plugins-disabled/
COPY --from=build-plugin-dicomweb /build/libOrthancDicomWeb.so /usr/share/orhtanc/plugins-disabled/
COPY --from=build-plugin-wsi /build/libOrthancWSI.so /usr/share/orhtanc/plugins-disabled/
COPY --from=build-plugin-wsi /build/OrthancWSIDicomToTiff /usr/local/bin/
COPY --from=build-plugin-wsi /build/OrthancWSIDicomizer /usr/local/bin/
COPY --from=build-plugin-wsi /build/libOrthancWSI.so /usr/share/orhtanc/plugins-disabled/
COPY --from=build-plugin-auth /build/libOrthancAuthorization.so /usr/share/orhtanc/plugins-disabled/
COPY --from=build-plugin-owv /build/libOrthancWebViewer.so /usr/share/orhtanc/plugins-disabled/
COPY --from=build-plugin-gcp /build/libOrthancGoogleCloudPlatform.so /usr/share/orhtanc/plugins-disabled/

# CHANGE_VERSION_WVB
RUN wget http://orthanc.osimis.io/lsb/plugin-osimis-webviewer/releases/1.3.1/libOsimisWebViewer.so --output-document /usr/share/orthanc/plugins-disabled/libOsimisWebViewer.so --quiet
# CHANGE_VERSION_WVB_ALPHA
RUN wget http://orthanc.osimis.io/lsb/plugin-osimis-webviewer/commits/35889ad3/libOsimisWebViewer.so --output-document /usr/share/orthanc/plugins-disabled/libOsimisWebViewerAlpha.so --quiet

RUN chmod +x /usr/share/orthanc/plugins-disabled/*


SHELL ["/bin/bash", "-c"]
ENTRYPOINT ["/usr/local/bin/Orthanc"]
CMD ["/etc/orthanc"]
