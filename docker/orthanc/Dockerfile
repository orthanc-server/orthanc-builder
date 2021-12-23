########################## Orthanc

FROM osimis/orthanc-builder-base:current as build-orthanc

# CHANGE_VERSION_ORTHANC
RUN hg clone https://hg.orthanc-server.com/orthanc/ -r "Orthanc-1.9.7" /sources
WORKDIR /build

# note: building with static DCMTL while waiting for Debian bullseye to fix Dicom TLS issues (we need DCMTK 3.6.5)
RUN cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DSTANDALONE_BUILD=ON -DUSE_GOOGLE_TEST_DEBIAN_PACKAGE=ON -DUSE_SYSTEM_CIVETWEB=OFF -DUSE_SYSTEM_DCMTK=OFF /sources/OrthancServer
RUN make -j 4
RUN /build/UnitTests

########################## Orthanc GDCM

FROM osimis/orthanc-builder-base:current as build-gdcm

# CHANGE_VERSION_GDCM
RUN hg clone https://hg.orthanc-server.com/orthanc-gdcm/ -r "OrthancGdcm-1.4" /sources
WORKDIR /build
RUN cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DSTATIC_BUILD=ON /sources
RUN make -j 4

########################## Orthanc PG

FROM osimis/orthanc-builder-base:current as build-plugin-pg

RUN apt-get --assume-yes update
RUN apt-get --assume-yes install libpq-dev postgresql-server-dev-all

# CHANGE_VERSION_PG
RUN hg clone https://hg.orthanc-server.com/orthanc-databases/ -r "OrthancPostgreSQL-4.0" /sources
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

# CHANGE_VERSION_MYSQL
RUN hg clone https://hg.orthanc-server.com/orthanc-databases/ -r "OrthancMySQL-4.3" /sources
WORKDIR /build
RUN cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF /sources/MySQL
RUN make -j 4
# disabled: needs a MySQL server # RUN /build/UnitTests

########################## Orthanc Transfers

FROM osimis/orthanc-builder-base:current as build-plugin-transfers

# CHANGE_VERSION_TRANSFERS
RUN hg clone https://hg.orthanc-server.com/orthanc-transfers/ -r "49e9245b4005" /sources
WORKDIR /build

RUN cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF /sources
RUN make -j 4

RUN /build/UnitTests

########################## Orthanc Dicomweb

FROM osimis/orthanc-builder-base:current as build-plugin-dicomweb

# CHANGE_VERSION_DW
RUN hg clone https://hg.orthanc-server.com/orthanc-dicomweb/ -r "OrthancDicomWeb-1.7" /sources
WORKDIR /build
RUN cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF /sources
RUN make -j 4
RUN /build/UnitTests

########################## Orthanc WSI

FROM osimis/orthanc-builder-base:current as build-plugin-wsi

# CHANGE_VERSION_ORTHANC_WSI
RUN hg clone https://hg.orthanc-server.com/orthanc-wsi/ -r "OrthancWSI-1.1" /sources
WORKDIR /build
RUN cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF -DUSE_SYSTEM_OPENJPEG=OFF /sources/ViewerPlugin
RUN make -j 4
# disabled: no unit tests: # RUN /build/UnitTests

RUN mkdir /downloads

RUN wget https://orthanc.osimis.io/lsb/whole-slide-imaging/releases/1.1/OrthancWSIDicomToTiff --output-document /downloads/OrthancWSIDicomToTiff --quiet
RUN wget https://orthanc.osimis.io/lsb/whole-slide-imaging/releases/1.1/OrthancWSIDicomizer --output-document /downloads/OrthancWSIDicomizer --quiet

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
RUN apt-get --assume-yes install python3-dev

# CHANGE_VERSION_ORTHANC_PYTHON
RUN hg clone https://hg.orthanc-server.com/orthanc-python/ -r "OrthancPython-3.4" /sources
WORKDIR /build
RUN cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF -DPYTHON_VERSION=3.9 /sources
RUN make -j 4
# disabled: no unit tests: # RUN /build/UnitTests

########################## Orthanc ODBC

FROM osimis/orthanc-builder-base:current as build-plugin-odbc

RUN apt-get --assume-yes update
RUN apt-get --assume-yes install unixodbc-dev

# CHANGE_VERSION_ODBC
RUN hg clone https://hg.orthanc-server.com/orthanc-databases/ -r "OrthancOdbc-1.1" /sources
WORKDIR /build
RUN cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF /sources/Odbc
RUN make -j 4
# disabled: needs a ODBC server # RUN /build/UnitTests

########################## Orthanc Indexer

FROM osimis/orthanc-builder-base:current as build-plugin-indexer

# CHANGE_VERSION_INDEXER
RUN hg clone https://hg.orthanc-server.com/orthanc-indexer/ -r "OrthancIndexer-1.0" /sources
WORKDIR /build
RUN cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF -DUSE_SYSTEM_LIBCSV=OFF /sources
RUN make -j 4

########################## Orthanc TCIA

FROM osimis/orthanc-builder-base:current as build-plugin-tcia

# CHANGE_VERSION_TCIA
RUN hg clone https://hg.orthanc-server.com/orthanc-tcia/ -r "OrthancTcia-1.1" /sources
WORKDIR /build
RUN cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF -DUSE_SYSTEM_LIBCSV=OFF /sources
RUN make -j 4

########################## Orthanc Stone Viewer

FROM osimis/orthanc-builder-base:current as build-stone-viewer

ARG STONEVIEWER_VERSION

RUN mkdir /downloads
# CHANGE_VERSION_STONE_WEB_VIEWER
RUN wget https://lsb.orthanc-server.com/stone-webviewer/2.2/wasm-binaries.zip --output-document /downloads/wasm-binaries.zip --quiet
RUN unzip /downloads/wasm-binaries.zip -d /downloads

# CHANGE_VERSION_STONE_WEB_VIEWER
RUN hg clone https://hg.orthanc-server.com/orthanc-stone/ -r "StoneWebViewer-2.2" /sources
WORKDIR /build
RUN cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF -DORTHANC_STONE_BINARIES=/downloads/wasm-binaries/StoneWebViewer /sources/Applications/StoneWebViewer/Plugin/
RUN make -j 4

########################## Orthanc downloads (since wget is not in the runner image)

FROM osimis/orthanc-builder-base:current as build-downloader

RUN mkdir /downloads

# CHANGE_VERSION_WVB (LSB are still built by Jenkins because jenkins is also building the frontend)
RUN wget https://orthanc.osimis.io/lsb/plugin-osimis-webviewer/releases/1.4.2/libOsimisWebViewer.so --output-document /downloads/libOsimisWebViewer.so --quiet
# CHANGE_VERSION_WVB_ALPHA
RUN wget https://orthanc.osimis.io/lsb/plugin-osimis-webviewer/releases/1.4.2/libOsimisWebViewer.so --output-document /downloads/libOsimisWebViewerAlpha.so --quiet


################################# the image that will run Orthanc dynamicaly linked
FROM osimis/orthanc-runner-base:current

RUN mkdir -p /etc/orthanc
RUN mkdir -p /usr/share/orthanc/plugins-available && \
	ln --symbolic /usr/share/orthanc/plugins-available /usr/share/orthanc/plugins-disabled && \
	echo "plugins-disabled is deprecated, please source plugins from plugins-available instead" >/usr/share/orthanc/plugins-disabled.README
RUN mkdir -p /usr/share/orthanc/plugins/

COPY --from=build-orthanc /build/Orthanc /usr/local/bin/
COPY --from=build-orthanc /build/libModalityWorklists.so /usr/share/orthanc/plugins-available/
COPY --from=build-orthanc /build/libServeFolders.so /usr/share/orthanc/plugins-available/
COPY --from=build-orthanc /build/libConnectivityChecks.so /usr/share/orthanc/plugins-available/
# RUN ldd /usr/bin/Orthanc

COPY --from=build-plugin-pg /build/libOrthancPostgreSQLIndex.so /usr/share/orthanc/plugins-available/
COPY --from=build-plugin-pg /build/libOrthancPostgreSQLStorage.so /usr/share/orthanc/plugins-available/
COPY --from=build-plugin-mysql /build/libOrthancMySQLIndex.so /usr/share/orthanc/plugins-available/
COPY --from=build-plugin-mysql /build/libOrthancMySQLStorage.so /usr/share/orthanc/plugins-available/
COPY --from=build-plugin-transfers /build/libOrthancTransfers.so /usr/share/orthanc/plugins-available/
COPY --from=build-plugin-dicomweb /build/libOrthancDicomWeb.so /usr/share/orthanc/plugins-available/
COPY --from=build-plugin-wsi /build/libOrthancWSI.so /usr/share/orthanc/plugins-available/
COPY --from=build-plugin-wsi /downloads/OrthancWSIDicomToTiff /usr/local/bin/
COPY --from=build-plugin-wsi /downloads/OrthancWSIDicomizer /usr/local/bin/
COPY --from=build-plugin-wsi /build/libOrthancWSI.so /usr/share/orthanc/plugins-available/
COPY --from=build-plugin-auth /build/libOrthancAuthorization.so /usr/share/orthanc/plugins-available/
COPY --from=build-plugin-owv /build/libOrthancWebViewer.so /usr/share/orthanc/plugins-available/
COPY --from=build-plugin-python /build/libOrthancPython.so /usr/share/orthanc/plugins-available/
COPY --from=build-gdcm /build/libOrthancGdcm.so /usr/share/orthanc/plugins-available/
COPY --from=build-plugin-odbc /build/libOrthancOdbcIndex.so /usr/share/orthanc/plugins-available/
COPY --from=build-plugin-odbc /build/libOrthancOdbcStorage.so /usr/share/orthanc/plugins-available/
COPY --from=build-plugin-tcia /build/libOrthancTcia.so /usr/share/orthanc/plugins-available/
COPY --from=build-plugin-indexer /build/libOrthancIndexer.so /usr/share/orthanc/plugins-available/
COPY --from=build-stone-viewer /build/libStoneWebViewer.so /usr/share/orthanc/plugins-available/

COPY --from=build-downloader /downloads/libOsimisWebViewer.so /usr/share/orthanc/plugins-available/
COPY --from=build-downloader /downloads/libOsimisWebViewerAlpha.so /usr/share/orthanc/plugins-available/

# If the target architecture is not AMD64, then delete the OsimisWebViewer &
# OsimisWebViewerAlpha plugin as they are only compatible with AMD64 builds
RUN if [[ ! -z "$TARGETPLATFORM" ]] && [[ "$TARGETPLATFORM" != "linux/amd64" ]]; then \
	rm /usr/share/orthanc/plugins-available/libOsimisWebViewer.so && \
	rm /usr/share/orthanc/plugins-available/libOsimisWebViewerAlpha.so; \
	fi

RUN chmod +x /usr/share/orthanc/plugins-available/*
RUN chmod +x /usr/local/bin/*

SHELL ["/bin/bash", "-c"]
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/tmp/orthanc.json"]

ENV MALLOC_ARENA_MAX=5
COPY docker-entrypoint.sh /
COPY *.json /startup/ 
COPY generateConfiguration.py /startup/
COPY helpers.py /startup/
COPY configurator.py /startup/
COPY *.lua /lua-scripts/
COPY test-aliveness.py /probes/


# cleanup unnecessary packages that can trigger errors during security scan
RUN apt purge --assume-yes build-essential
RUN apt purge --assume-yes perl
RUN apt purge --assume-yes bzip2
RUN apt purge --assume-yes gnupg
RUN apt purge --assume-yes xdg-user-dirs
RUN apt --assume-yes autoremove
