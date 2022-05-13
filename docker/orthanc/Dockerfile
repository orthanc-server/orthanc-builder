ARG BASE_IMAGE_TAG=current

FROM osimis/orthanc-builder-base:${BASE_IMAGE_TAG} as orthanc-builder-base

FROM osimis/orthanc-runner-base:${BASE_IMAGE_TAG} as orthanc-runner-base

FROM osimis/orthanc-builder-base:vcpkg-google-${BASE_IMAGE_TAG} as build-plugin-object-storage-google

FROM osimis/orthanc-builder-base:vcpkg-azure-${BASE_IMAGE_TAG} as build-plugin-object-storage-azure

########################## Orthanc

FROM orthanc-builder-base as build-orthanc

ARG ORTHANC_COMMIT_ID
RUN hg clone https://hg.orthanc-server.com/orthanc/ -r $ORTHANC_COMMIT_ID /sources
WORKDIR /build

# note: building with static DCMTL while waiting for Debian bullseye to fix Dicom TLS issues (we need DCMTK 3.6.5)
RUN cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DSTANDALONE_BUILD=ON -DUSE_GOOGLE_TEST_DEBIAN_PACKAGE=ON -DUSE_SYSTEM_CIVETWEB=OFF -DUSE_SYSTEM_DCMTK=OFF /sources/OrthancServer
RUN make -j 4
RUN /build/UnitTests

########################## Orthanc GDCM

FROM orthanc-builder-base as build-gdcm

ARG ORTHANC_GDCM_COMMIT_ID
RUN hg clone https://hg.orthanc-server.com/orthanc-gdcm/ -r $ORTHANC_GDCM_COMMIT_ID /sources
WORKDIR /build
RUN cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DSTATIC_BUILD=ON /sources
RUN make -j 4

########################## Orthanc PG

FROM orthanc-builder-base as build-plugin-pg

ARG ORTHANC_PG_COMMIT_ID
RUN hg clone https://hg.orthanc-server.com/orthanc-databases/ -r $ORTHANC_PG_COMMIT_ID /sources
WORKDIR /build
RUN cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF /sources/PostgreSQL
RUN make -j 4
# disabled: needs a PG server # RUN /build/UnitTests

########################## Orthanc MySQL

FROM orthanc-builder-base as build-plugin-mysql

ARG ORTHANC_MYSQL_COMMIT_ID
RUN hg clone https://hg.orthanc-server.com/orthanc-databases/ -r $ORTHANC_MYSQL_COMMIT_ID /sources
WORKDIR /build
RUN cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF /sources/MySQL
RUN make -j 4
# disabled: needs a MySQL server # RUN /build/UnitTests

########################## Orthanc Transfers

FROM orthanc-builder-base as build-plugin-transfers

ARG ORTHANC_TRANSFERS_COMMIT_ID
RUN hg clone https://hg.orthanc-server.com/orthanc-transfers/ -r $ORTHANC_TRANSFERS_COMMIT_ID /sources
WORKDIR /build

RUN cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF /sources
RUN make -j 4

RUN /build/UnitTests

########################## Orthanc Dicomweb

FROM orthanc-builder-base as build-plugin-dicomweb

ARG ORTHANC_DW_COMMIT_ID
RUN hg clone https://hg.orthanc-server.com/orthanc-dicomweb/ -r $ORTHANC_DW_COMMIT_ID /sources
WORKDIR /build
RUN cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF /sources
RUN make -j 4
RUN /build/UnitTests

########################## Orthanc WSI

FROM orthanc-builder-base as build-plugin-wsi

ARG ORTHANC_WSI_COMMIT_ID
RUN hg clone https://hg.orthanc-server.com/orthanc-wsi/ -r $ORTHANC_WSI_COMMIT_ID /sources
WORKDIR /build
RUN cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF -DUSE_SYSTEM_OPENJPEG=OFF /sources/ViewerPlugin
RUN make -j 4
# disabled: no unit tests: # RUN /build/UnitTests

RUN mkdir /downloads

# TODO: we should probably build these tools here as well
RUN wget https://orthanc.osimis.io/lsb/whole-slide-imaging/releases/1.1/OrthancWSIDicomToTiff --output-document /downloads/OrthancWSIDicomToTiff --quiet
RUN wget https://orthanc.osimis.io/lsb/whole-slide-imaging/releases/1.1/OrthancWSIDicomizer --output-document /downloads/OrthancWSIDicomizer --quiet

########################## Orthanc Webviewer

FROM orthanc-builder-base as build-plugin-owv

ARG ORTHANC_OWV_COMMIT_ID
RUN hg clone https://hg.orthanc-server.com/orthanc-webviewer/ -r $ORTHANC_OWV_COMMIT_ID /sources
WORKDIR /build
RUN cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF /sources
RUN make -j 4
RUN /build/UnitTests

########################## Orthanc authorization

FROM orthanc-builder-base as build-plugin-auth

ARG ORTHANC_AUTH_COMMIT_ID
RUN hg clone https://hg.orthanc-server.com/orthanc-authorization/ -r $ORTHANC_AUTH_COMMIT_ID /sources
WORKDIR /build
RUN cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF /sources
RUN make -j 4
# disabled: no unit tests: # RUN /build/UnitTests

########################## Orthanc Python

FROM orthanc-builder-base as build-plugin-python

ARG ORTHANC_PYTHON_COMMIT_ID
RUN hg clone https://hg.orthanc-server.com/orthanc-python/ -r $ORTHANC_PYTHON_COMMIT_ID /sources
WORKDIR /build
RUN cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF -DPYTHON_VERSION=3.9 /sources
RUN make -j 4
# disabled: no unit tests: # RUN /build/UnitTests

########################## Orthanc ODBC

FROM orthanc-builder-base as build-plugin-odbc

ARG ORTHANC_ODBC_COMMIT_ID
RUN hg clone https://hg.orthanc-server.com/orthanc-databases/ -r $ORTHANC_ODBC_COMMIT_ID /sources
WORKDIR /build
RUN cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF /sources/Odbc
RUN make -j 4
# disabled: needs a ODBC server # RUN /build/UnitTests

########################## Orthanc Indexer

FROM orthanc-builder-base as build-plugin-indexer

ARG ORTHANC_INDEXER_COMMIT_ID
RUN hg clone https://hg.orthanc-server.com/orthanc-indexer/ -r $ORTHANC_INDEXER_COMMIT_ID /sources
WORKDIR /build
RUN cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF -DUSE_SYSTEM_LIBCSV=OFF /sources
RUN make -j 4

########################## Orthanc Neuro

FROM orthanc-builder-base as build-plugin-neuro

ARG ORTHANC_NEURO_COMMIT_ID
RUN hg clone https://hg.orthanc-server.com/orthanc-neuro/ -r $ORTHANC_NEURO_COMMIT_ID /sources
WORKDIR /build
RUN cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF -DUSE_SYSTEM_NIFTILIB=OFF /sources
RUN make -j 4

########################## Orthanc TCIA

FROM orthanc-builder-base as build-plugin-tcia

ARG ORTHANC_TCIA_COMMIT_ID
RUN hg clone https://hg.orthanc-server.com/orthanc-tcia/ -r $ORTHANC_TCIA_COMMIT_ID /sources
WORKDIR /build
RUN cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF -DUSE_SYSTEM_LIBCSV=OFF /sources
RUN make -j 4

########################## Stone Web Viewer

FROM jodogne/wasm-builder:2.0.23 as build-wasm-stone-viewer

# TODO for ARM64,... problem: emsdk 2.0.23 does not exist for ARM64 and stone is not ready to build with 3.1.8
# this is equivalent to the jodogne/wasm-builder:2.0.23 image (it is copied here such that it builds smoothly on ARM64 platform too!)
# FROM ubuntu:18.04 as build-wasm-stone-viewer

# RUN apt-get -y clean && apt-get -y update
# RUN DEBIAN_FRONTEND=noninteractive apt-get -y install wget nano unzip cmake git ninja-build python-clang-4.0 libclang-4.0-dev python-pystache python-pip alien lsb-core g++-4.8 && apt-get clean && rm -rf /var/lib/apt/lists/*
# RUN DEBIAN_FRONTEND=noninteractive apt-get -y install alien ninja-build 

# WORKDIR /opt
# RUN git clone https://github.com/emscripten-core/emsdk.git
# RUN /opt/emsdk/emsdk install 3.1.8
# RUN /opt/emsdk/emsdk actviate 3.1.8


ARG ORTHANC_STONE_VIEWER_COMMIT_ID

RUN hg clone https://hg.orthanc-server.com/orthanc-stone/ -r $ORTHANC_STONE_VIEWER_COMMIT_ID /source

WORKDIR /source/Applications/StoneWebViewer/WebAssembly
RUN chmod +x docker-internal.sh
RUN ./docker-internal.sh Release


FROM orthanc-builder-base as build-stone-viewer

ARG ORTHANC_STONE_VIEWER_COMMIT_ID

RUN mkdir -p /downloads/wasm-binaries/StoneWebViewer
COPY --from=build-wasm-stone-viewer /target/StoneWebViewer/ /downloads/wasm-binaries/StoneWebViewer
RUN ls -al /downloads/wasm-binaries/StoneWebViewer

# RUN mkdir /downloads
# # CHANGE_VERSION_STONE_WEB_VIEWER
# RUN wget https://lsb.orthanc-server.com/stone-webviewer/2.3/wasm-binaries.zip --output-document /downloads/wasm-binaries.zip --quiet
# RUN unzip /downloads/wasm-binaries.zip -d /downloads

# CHANGE_VERSION_STONE_WEB_VIEWER
RUN hg clone https://hg.orthanc-server.com/orthanc-stone/ -r $ORTHANC_STONE_VIEWER_COMMIT_ID /sources
WORKDIR /build
RUN cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF -DORTHANC_STONE_BINARIES=/downloads/wasm-binaries/StoneWebViewer /sources/Applications/StoneWebViewer/Plugin/
RUN make -j 4


########################## Orthanc azure storage plugins

FROM build-plugin-object-storage-azure as build-azure-object-storage

ARG ORTHANC_AZURE_STORAGE_COMMIT_ID

WORKDIR /sources
RUN hg clone https://hg.orthanc-server.com/orthanc-object-storage/ -r $ORTHANC_AZURE_STORAGE_COMMIT_ID

# (framework version used to build the cloud storage plugins)
RUN hg clone https://hg.orthanc-server.com/orthanc/ -r "Orthanc-1.10.1" 

# upgrade cmake minimum version to fix a Boost_FIND_COMPONENTS error: https://stackoverflow.com/questions/62930429/c-avro-cmake-failed
RUN sed -i 's/cmake_minimum_required(VERSION 2.8)/cmake_minimum_required(VERSION 3.3)/g' /sources/orthanc-object-storage/Azure/CMakeLists.txt

RUN mkdir -p /build/cloud-storage/azure
WORKDIR /build/cloud-storage/azure

RUN cmake -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_TOOLCHAIN_FILE=/vcpkg/scripts/buildsystems/vcpkg.cmake -DORTHANC_FRAMEWORK_SOURCE=path -DORTHANC_FRAMEWORK_ROOT=/sources/orthanc/OrthancFramework/Sources /sources/orthanc-object-storage/Azure/
RUN make -j 4


########################## Orthanc Google storage plugins

FROM build-plugin-object-storage-google as build-google-object-storage

WORKDIR /sources

ARG ORTHANC_GOOGLE_STORAGE_COMMIT_ID
RUN hg clone https://hg.orthanc-server.com/orthanc-object-storage/ -r $ORTHANC_GOOGLE_STORAGE_COMMIT_ID

# (framework version used to build the cloud storage plugins)
RUN hg clone https://hg.orthanc-server.com/orthanc/ -r "Orthanc-1.10.1" 

# upgrade cmake minimum version to fix a Boost_FIND_COMPONENTS error: https://stackoverflow.com/questions/62930429/c-avro-cmake-failed
RUN sed -i 's/cmake_minimum_required(VERSION 2.8)/cmake_minimum_required(VERSION 3.3)/g' /sources/orthanc-object-storage/Google/CMakeLists.txt

RUN mkdir -p /build/cloud-storage/google
WORKDIR /build/cloud-storage/google
RUN cmake -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_TOOLCHAIN_FILE=/vcpkg/scripts/buildsystems/vcpkg.cmake -DORTHANC_FRAMEWORK_SOURCE=path -DORTHANC_FRAMEWORK_ROOT=/sources/orthanc/OrthancFramework/Sources /sources/orthanc-object-storage/Google/
RUN make -j 4


########################## Orthanc s3 object storage plugins

FROM orthanc-builder-base as build-s3-object-storage

WORKDIR /

# prerequisites (for object-storage client side encryption)
RUN export DEBIAN_FRONTEND=noninteractive && \
	apt-get --assume-yes update && \
		apt-get --assume-yes install libcrypto++-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /sources

ARG ORTHANC_AWS_STORAGE_COMMIT_ID
RUN hg clone https://hg.orthanc-server.com/orthanc-object-storage/ -r $ORTHANC_AWS_STORAGE_COMMIT_ID

# (framework version used to build the cloud storage plugins)
RUN hg clone https://hg.orthanc-server.com/orthanc/ -r "Orthanc-1.10.1" 

RUN mkdir -p /build/cloud-storage/aws
WORKDIR /build/cloud-storage/aws
RUN cmake -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_VCPKG_PACKAGES=OFF -DORTHANC_FRAMEWORK_SOURCE=path -DORTHANC_FRAMEWORK_ROOT=/sources/orthanc/OrthancFramework/Sources /sources/orthanc-object-storage/Aws/
RUN make -j 4


########################## Orthanc Explorer 2

FROM orthanc-builder-base as build-oe2

RUN export DEBIAN_FRONTEND=noninteractive && \
	apt-get --assume-yes update && \
	apt-get --assume-yes install nodejs npm && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ARG ORTHANC_OE2_COMMIT_ID
WORKDIR /sources

RUN git clone https://github.com/orthanc-server/orthanc-explorer-2.git && \
    cd /sources/orthanc-explorer-2 && \
	git checkout $ORTHANC_OE2_COMMIT_ID

WORKDIR /sources/orthanc-explorer-2/WebApplication

RUN npm install
RUN npm run build

WORKDIR /build
RUN cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_ORTHANC_SDK=OFF /sources/orthanc-explorer-2/
RUN make -j 4


########################## Orthanc downloads (since wget is not in the runner image)

FROM orthanc-builder-base as build-downloader

RUN mkdir /downloads

# CHANGE_VERSION_WVB (LSB are still built by Jenkins because jenkins is also building the frontend)
RUN wget https://orthanc.osimis.io/lsb/plugin-osimis-webviewer/releases/1.4.2/libOsimisWebViewer.so --output-document /downloads/libOsimisWebViewer.so --quiet
# CHANGE_VERSION_WVB_ALPHA
RUN wget https://orthanc.osimis.io/lsb/plugin-osimis-webviewer/releases/1.4.2/libOsimisWebViewer.so --output-document /downloads/libOsimisWebViewerAlpha.so --quiet


################################# the image that will run Orthanc dynamicaly linked (intermediate version without vcpkg builds)
FROM orthanc-runner-base as orthanc-no-vcpkg

RUN mkdir -p /etc/orthanc
RUN mkdir -p /usr/share/orthanc/plugins-available && \
	ln --symbolic /usr/share/orthanc/plugins-available /usr/share/orthanc/plugins-disabled && \
	echo "plugins-disabled is deprecated, please source plugins from plugins-available instead" >/usr/share/orthanc/plugins-disabled.README
RUN mkdir -p /usr/share/orthanc/plugins/

COPY --from=build-orthanc /build/Orthanc /usr/local/bin/
COPY --from=build-orthanc /build/libModalityWorklists.so /usr/share/orthanc/plugins-available/
COPY --from=build-orthanc /build/libServeFolders.so /usr/share/orthanc/plugins-available/
COPY --from=build-orthanc /build/libConnectivityChecks.so /usr/share/orthanc/plugins-available/
COPY --from=build-orthanc /build/libHousekeeper.so /usr/share/orthanc/plugins-available/
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
COPY --from=build-plugin-auth /build/libOrthancAuthorization.so /usr/share/orthanc/plugins-available/
COPY --from=build-plugin-owv /build/libOrthancWebViewer.so /usr/share/orthanc/plugins-available/
COPY --from=build-plugin-python /build/libOrthancPython.so /usr/share/orthanc/plugins-available/
COPY --from=build-gdcm /build/libOrthancGdcm.so /usr/share/orthanc/plugins-available/
COPY --from=build-plugin-odbc /build/libOrthancOdbcIndex.so /usr/share/orthanc/plugins-available/
COPY --from=build-plugin-odbc /build/libOrthancOdbcStorage.so /usr/share/orthanc/plugins-available/
COPY --from=build-plugin-tcia /build/libOrthancTcia.so /usr/share/orthanc/plugins-available/
COPY --from=build-plugin-indexer /build/libOrthancIndexer.so /usr/share/orthanc/plugins-available/
COPY --from=build-plugin-neuro /build/libOrthancNeuro.so /usr/share/orthanc/plugins-available/
COPY --from=build-stone-viewer /build/libStoneWebViewer.so /usr/share/orthanc/plugins-available/
COPY --from=build-oe2 /build/libOrthancExplorer2.so /usr/share/orthanc/plugins-available/

COPY --from=build-downloader /downloads/libOsimisWebViewer.so /usr/share/orthanc/plugins-available/
COPY --from=build-downloader /downloads/libOsimisWebViewerAlpha.so /usr/share/orthanc/plugins-available/

COPY --from=build-s3-object-storage /build/cloud-storage/aws/libOrthancAwsS3Storage.so /usr/share/orthanc/plugins-available/

# If the target architecture is not AMD64, then delete the OsimisWebViewer &
# OsimisWebViewerAlpha plugin as they are only compatible with AMD64 builds
RUN if [[ ! -z "$TARGETPLATFORM" ]] && [[ "$TARGETPLATFORM" != "linux/amd64" ]]; then \
	rm /usr/share/orthanc/plugins-available/libOsimisWebViewer.so && \
	rm /usr/share/orthanc/plugins-available/libOsimisWebViewerAlpha.so; \
	fi

RUN chmod +x /usr/share/orthanc/plugins-available/*
RUN chmod +x /usr/local/bin/*

# configure SSL for azure rest sdk (azure object storage plugin)
ENV SSL_CERT_DIR=/etc/ssl/certs

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


################################# the image that will run Orthanc dynamicaly linked (final version with vcpkg builds)
FROM orthanc-no-vcpkg as orthanc-with-vcpkg

COPY --from=build-google-object-storage /build/cloud-storage/google/libOrthancGoogleCloudStorage.so /usr/share/orthanc/plugins-available/
COPY --from=build-azure-object-storage /build/cloud-storage/azure/libOrthancAzureBlobStorage.so /usr/share/orthanc/plugins-available/

RUN chmod +x /usr/share/orthanc/plugins-available/*
RUN chmod +x /usr/local/bin/*

