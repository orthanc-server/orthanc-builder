########################## Orthanc

FROM osimis/orthanc-builder-base:current as build-orthanc

# CHANGE_VERSION_ORTHANC
RUN hg clone https://hg.orthanc-server.com/orthanc/ -r "Orthanc-1.8.2" /sources
WORKDIR /build
RUN cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DSTANDALONE_BUILD=ON -DUSE_GOOGLE_TEST_DEBIAN_PACKAGE=ON -DUSE_SYSTEM_CIVETWEB=OFF /sources/OrthancServer
RUN make -j 4
RUN /build/UnitTests

########################## Orthanc GDCM

FROM osimis/orthanc-builder-base:current as build-gdcm

# CHANGE_VERSION_GDCM
RUN hg clone https://hg.orthanc-server.com/orthanc-gdcm/ -r "OrthancGdcm-1.2" /sources
WORKDIR /build
RUN cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DSTATIC_BUILD=ON /sources
RUN make -j 4

########################## Orthanc PG

FROM osimis/orthanc-builder-base:current as build-plugin-pg

RUN apt-get --assume-yes update
RUN apt-get --assume-yes install libpq-dev postgresql-server-dev-all

# CHANGE_VERSION_PG
RUN hg clone https://hg.orthanc-server.com/orthanc-databases/ -r "OrthancPostgreSQL-3.3" /sources
WORKDIR /build
RUN cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF /sources/PostgreSQL
RUN make -j 4
# disabled: needs a PG server # RUN /build/UnitTests

########################## Orthanc MySQL

FROM osimis/orthanc-builder-base:current as build-plugin-mysql

RUN apt-get --assume-yes update
# on recent Debian, the libmysql-dev package is not available anymore
# and the MariaDbConfiguration.cmake does not handle it correctly -> use the downloaded mariadb_client
RUN apt-get --assume-yes install default-libmysqlclient-dev
# RUN apt-get --assume-yes install libmariadb-dev

# CHANGE_VERSION_MY_SQL
RUN hg clone https://hg.orthanc-server.com/orthanc-databases/ -r "OrthancMySQL-3.0" /sources
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
RUN hg clone https://hg.orthanc-server.com/orthanc-dicomweb/ -r "OrthancDicomWeb-1.4" /sources
WORKDIR /build
RUN cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF /sources
RUN make -j 4
RUN /build/UnitTests

########################## Orthanc WSI

FROM osimis/orthanc-builder-base:current as build-plugin-wsi

# CHANGE_VERSION_ORTHANC_WSI
RUN hg clone https://hg.orthanc-server.com/orthanc-wsi/ -r "OrthancWSI-0.7" /sources
WORKDIR /build
RUN cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF -DUSE_SYSTEM_OPENJPEG=OFF /sources/ViewerPlugin
RUN make -j 4
# disabled: no unit tests: # RUN /build/UnitTests

########################## Orthanc Webviewer

FROM osimis/orthanc-builder-base:current as build-plugin-owv

# CHANGE_VERSION_ORTHANC_WEB_VIEWER
RUN hg clone https://hg.orthanc-server.com/orthanc-webviewer/ -r "OrthancWebViewer-2.7" /sources
WORKDIR /build
RUN cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF /sources
RUN make -j 4
RUN /build/UnitTests

########################## Orthanc authorization

FROM osimis/orthanc-builder-base:current as build-plugin-auth

# CHANGE_VERSION_AUTH
RUN hg clone https://hg.orthanc-server.com/orthanc-authorization/ -r "0.2.4" /sources
WORKDIR /build
RUN cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF /sources
RUN make -j 4
# disabled: no unit tests: # RUN /build/UnitTests

########################## Orthanc Python

FROM osimis/orthanc-builder-base:current as build-plugin-python

RUN apt-get --assume-yes update
RUN apt-get --assume-yes install python3.7-dev

# CHANGE_VERSION_ORTHANC_PYTHON
RUN hg clone https://hg.orthanc-server.com/orthanc-python/ -r "OrthancPython-3.0" /sources
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
COPY --from=build-orthanc /build/libModalityWorklists.so /usr/share/orthanc/plugins-disabled/
COPY --from=build-orthanc /build/libServeFolders.so /usr/share/orthanc/plugins-disabled/
COPY --from=build-orthanc /build/libConnectivityChecks.so /usr/share/orthanc/plugins-disabled/
# RUN ldd /usr/bin/Orthanc

COPY --from=build-plugin-pg /build/libOrthancPostgreSQLIndex.so /usr/share/orthanc/plugins-disabled/
COPY --from=build-plugin-pg /build/libOrthancPostgreSQLStorage.so /usr/share/orthanc/plugins-disabled/
COPY --from=build-plugin-mysql /build/libOrthancMySQLIndex.so /usr/share/orthanc/plugins-disabled/
COPY --from=build-plugin-mysql /build/libOrthancMySQLStorage.so /usr/share/orthanc/plugins-disabled/
COPY --from=build-plugin-transfers /build/libOrthancTransfers.so /usr/share/orthanc/plugins-disabled/
COPY --from=build-plugin-dicomweb /build/libOrthancDicomWeb.so /usr/share/orthanc/plugins-disabled/
COPY --from=build-plugin-wsi /build/libOrthancWSI.so /usr/share/orthanc/plugins-disabled/
# currently not built COPY --from=build-plugin-wsi /build/OrthancWSIDicomToTiff /usr/local/bin/
# currently not built COPY --from=build-plugin-wsi /build/OrthancWSIDicomizer /usr/local/bin/
COPY --from=build-plugin-wsi /build/libOrthancWSI.so /usr/share/orthanc/plugins-disabled/
COPY --from=build-plugin-auth /build/libOrthancAuthorization.so /usr/share/orthanc/plugins-disabled/
COPY --from=build-plugin-owv /build/libOrthancWebViewer.so /usr/share/orthanc/plugins-disabled/
COPY --from=build-plugin-python /build/libOrthancPython.so /usr/share/orthanc/plugins-disabled/
COPY --from=build-gdcm /build/libOrthancGdcm.so /usr/share/orthanc/plugins-disabled/



# CHANGE_VERSION_WVB (LSB are still built by Jenkins because jenkins is also building the frontend)
RUN wget http://orthanc.osimis.io/lsb/plugin-osimis-webviewer/releases/1.4.2/libOsimisWebViewer.so --output-document /usr/share/orthanc/plugins-disabled/libOsimisWebViewer.so --quiet
# CHANGE_VERSION_WVB_ALPHA
RUN wget http://orthanc.osimis.io/lsb/plugin-osimis-webviewer/releases/1.4.2/libOsimisWebViewer.so --output-document /usr/share/orthanc/plugins-disabled/libOsimisWebViewerAlpha.so --quiet
# CHANGE_VERSION_OSIMIS_CLOUD
RUN wget http://orthanc.osimis.io/lsb/plugin-osimis-cloud/releases/0.3/libOrthancOsimisCloud.so --output-document /usr/share/orthanc/plugins-disabled/libOrthancOsimisCloud.so --quiet
# CHANGE_VERSION_STONE_WEB_VIEWER
RUN wget http://orthanc.osimis.io/lsb/stone-webviewer/releases/1.0/libStoneWebViewer.so --output-document /usr/share/orthanc/plugins-disabled/libStoneWebViewer.so --quiet

RUN chmod +x /usr/share/orthanc/plugins-disabled/*

SHELL ["/bin/bash", "-c"]
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/tmp/orthanc.json"]

ENV MALLOC_ARENA_MAX=5
COPY docker-entrypoint.sh /
COPY *.json /startup/ 
COPY *.py /startup/
COPY *.lua /lua-scripts/
