ARG BASE_IMAGE_TAG=bullseye-20220125

FROM osimis/orthanc-builder-base:${BASE_IMAGE_TAG} as orthanc-builder-base

FROM osimis/orthanc-runner-base:${BASE_IMAGE_TAG} as orthanc-runner-base

FROM osimis/orthanc-builder-base:vcpkg-google-${BASE_IMAGE_TAG} as build-plugin-object-storage-google

FROM osimis/orthanc-builder-base:vcpkg-azure-${BASE_IMAGE_TAG} as build-plugin-object-storage-azure

########################## Orthanc

FROM orthanc-builder-base as build-orthanc

# CHANGE_VERSION_ORTHANC
RUN hg clone https://hg.orthanc-server.com/orthanc/ -r "d68b3a2cea17" /sources
WORKDIR /build

# note: building with static DCMTL while waiting for Debian bullseye to fix Dicom TLS issues (we need DCMTK 3.6.5)
RUN cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DSTANDALONE_BUILD=ON -DUSE_GOOGLE_TEST_DEBIAN_PACKAGE=ON -DUSE_SYSTEM_CIVETWEB=OFF -DUSE_SYSTEM_DCMTK=OFF /sources/OrthancServer
RUN make -j 4
RUN /build/UnitTests

########################## Orthanc GDCM

FROM orthanc-builder-base as build-gdcm

# CHANGE_VERSION_GDCM
RUN hg clone https://hg.orthanc-server.com/orthanc-gdcm/ -r "OrthancGdcm-1.5" /sources
WORKDIR /build
RUN cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DSTATIC_BUILD=ON /sources
RUN make -j 4

########################## Orthanc PG

FROM orthanc-builder-base as build-plugin-pg

# CHANGE_VERSION_PG
RUN hg clone https://hg.orthanc-server.com/orthanc-databases/ -r "OrthancPostgreSQL-4.0" /sources
WORKDIR /build
RUN cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF /sources/PostgreSQL
RUN make -j 4
# disabled: needs a PG server # RUN /build/UnitTests

########################## Orthanc MySQL

FROM orthanc-builder-base as build-plugin-mysql

# CHANGE_VERSION_MYSQL
RUN hg clone https://hg.orthanc-server.com/orthanc-databases/ -r "OrthancMySQL-4.3" /sources
WORKDIR /build
RUN cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF /sources/MySQL
RUN make -j 4
# disabled: needs a MySQL server # RUN /build/UnitTests

########################## Orthanc Transfers

FROM orthanc-builder-base as build-plugin-transfers

# CHANGE_VERSION_TRANSFERS
RUN hg clone https://hg.orthanc-server.com/orthanc-transfers/ -r "49e9245b4005" /sources
WORKDIR /build

RUN cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF /sources
RUN make -j 4

RUN /build/UnitTests

########################## Orthanc Dicomweb

FROM orthanc-builder-base as build-plugin-dicomweb

# CHANGE_VERSION_DW
RUN hg clone https://hg.orthanc-server.com/orthanc-dicomweb/ -r "c76d81c6fee8" /sources
WORKDIR /build
RUN cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF /sources
RUN make -j 4
RUN /build/UnitTests

########################## Orthanc WSI

FROM orthanc-builder-base as build-plugin-wsi

# CHANGE_VERSION_WSI
RUN hg clone https://hg.orthanc-server.com/orthanc-wsi/ -r "OrthancWSI-1.1" /sources
WORKDIR /build
RUN cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF -DUSE_SYSTEM_OPENJPEG=OFF /sources/ViewerPlugin
RUN make -j 4
# disabled: no unit tests: # RUN /build/UnitTests

RUN mkdir /downloads

RUN wget https://orthanc.osimis.io/lsb/whole-slide-imaging/releases/1.1/OrthancWSIDicomToTiff --output-document /downloads/OrthancWSIDicomToTiff --quiet
RUN wget https://orthanc.osimis.io/lsb/whole-slide-imaging/releases/1.1/OrthancWSIDicomizer --output-document /downloads/OrthancWSIDicomizer --quiet

########################## Orthanc Webviewer

FROM orthanc-builder-base as build-plugin-owv

# CHANGE_VERSION_ORTHANC_WEB_VIEWER
RUN hg clone https://hg.orthanc-server.com/orthanc-webviewer/ -r "OrthancWebViewer-2.8" /sources
WORKDIR /build
RUN cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF /sources
RUN make -j 4
RUN /build/UnitTests

########################## Orthanc authorization

FROM orthanc-builder-base as build-plugin-auth

# CHANGE_VERSION_AUTH
RUN hg clone https://hg.orthanc-server.com/orthanc-authorization/ -r "0.2.4" /sources
WORKDIR /build
RUN cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF /sources
RUN make -j 4
# disabled: no unit tests: # RUN /build/UnitTests

########################## Orthanc Python

FROM orthanc-builder-base as build-plugin-python

# CHANGE_VERSION_ORTHANC_PYTHON
RUN hg clone https://hg.orthanc-server.com/orthanc-python/ -r "OrthancPython-4.0" /sources
WORKDIR /build
RUN cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF -DPYTHON_VERSION=3.9 /sources
RUN make -j 4
# disabled: no unit tests: # RUN /build/UnitTests

########################## Orthanc ODBC

FROM orthanc-builder-base as build-plugin-odbc

# CHANGE_VERSION_ODBC
RUN hg clone https://hg.orthanc-server.com/orthanc-databases/ -r "OrthancOdbc-1.1" /sources
WORKDIR /build
RUN cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF /sources/Odbc
RUN make -j 4
# disabled: needs a ODBC server # RUN /build/UnitTests

########################## Orthanc Indexer

FROM orthanc-builder-base as build-plugin-indexer

# CHANGE_VERSION_INDEXER
RUN hg clone https://hg.orthanc-server.com/orthanc-indexer/ -r "OrthancIndexer-1.0" /sources
WORKDIR /build
RUN cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF -DUSE_SYSTEM_LIBCSV=OFF /sources
RUN make -j 4

########################## Orthanc TCIA

FROM orthanc-builder-base as build-plugin-tcia

# CHANGE_VERSION_TCIA
RUN hg clone https://hg.orthanc-server.com/orthanc-tcia/ -r "OrthancTcia-1.1" /sources
WORKDIR /build
RUN cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF -DUSE_SYSTEM_LIBCSV=OFF /sources
RUN make -j 4

########################## Stone Web Viewer

FROM orthanc-builder-base as build-stone-viewer

ARG STONEVIEWER_VERSION

RUN mkdir /downloads
# CHANGE_VERSION_STONE_WEB_VIEWER
RUN wget https://lsb.orthanc-server.com/stone-webviewer/2.3/wasm-binaries.zip --output-document /downloads/wasm-binaries.zip --quiet
RUN unzip /downloads/wasm-binaries.zip -d /downloads

# CHANGE_VERSION_STONE_WEB_VIEWER
RUN hg clone https://hg.orthanc-server.com/orthanc-stone/ -r "StoneWebViewer-2.3" /sources
WORKDIR /build
RUN cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF -DORTHANC_STONE_BINARIES=/downloads/wasm-binaries/StoneWebViewer /sources/Applications/StoneWebViewer/Plugin/
RUN make -j 4


# ########################## vcpkg cache

# # create vcpkg cache.  This task takes a lot of time and only needs to be
# # performed when the build system is updated -> it should be commented out
# # most of the time

# FROM orthanc-builder-base as vcpkg-cache-generator

# ARG AWS_ACCESS_KEY_ID
# ENV AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
# ARG AWS_SECRET_ACCESS_KEY
# ENV AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY

# RUN pip3 install awscli

# WORKDIR /

# RUN git clone https://github.com/Microsoft/vcpkg.git && \
#   cd vcpkg/ && \
#   git checkout 2021.05.12

# WORKDIR /vcpkg
# RUN ./bootstrap-vcpkg.sh
# RUN ./vcpkg integrate install

# # object storage prerequisites
# RUN  ./vcpkg install cryptopp

# # since we upgraded from Orthanc Framework 1.7.3 to 1.9.1
# RUN  ./vcpkg install boost

# # Google prerequisites
# RUN  ./vcpkg install google-cloud-cpp

# RUN  ./vcpkg install azure-storage-cpp

# # export a snapshot to AWS (this snapshot is downloaded below to gain time)
# RUN ./vcpkg export --x-all-installed --zip --output=object-storage-vcpkg-2021.05.12-bullseye
# RUN aws s3 --region eu-west-1 cp object-storage-vcpkg-2021.05.12-bullseye.zip s3://orthanc.osimis.io/vcpkg/


# ########################## Orthanc object storage plugins

# FROM orthanc-builder-base as build-plugin-object-storage

# WORKDIR /

# # prerequisites (for VCPKG builds)
# RUN export DEBIAN_FRONTEND=noninteractive && \
# 	apt-get --assume-yes update && \
# 		apt-get --assume-yes install libcrypto++-dev ninja-build && \
#     apt-get clean && \
#     rm -rf /var/lib/apt/lists/*

# RUN git clone https://github.com/Microsoft/vcpkg.git && \
#   cd vcpkg/ && \
#   git checkout 2021.05.12
# WORKDIR /vcpkg
# # RUN ls -al /vcpkg
# RUN ./bootstrap-vcpkg.sh
# ENV VCPKG_FORCE_SYSTEM_BINARIES=1
# RUN ./vcpkg integrate install

# # object storage prerequisites
# RUN ./vcpkg install cryptopp

# # since we upgraded from Orthanc Framework 1.7.3 to 1.9.1
# RUN ./vcpkg install boost


########################## Orthanc azure storage plugins

FROM build-plugin-object-storage-azure as build-azure-object-storage

WORKDIR /sources
# CHANGE_VERSION_ORTHANC_CLOUD_STORAGE
RUN hg clone https://hg.orthanc-server.com/orthanc-object-storage/ -r 1.3.3

# CHANGE_VERSION_ORTHANC (framework version used to build the cloud storage plugins)
RUN hg clone https://hg.orthanc-server.com/orthanc/ -r "Orthanc-1.10.1" 

# upgrade cmake minimum version to fix a Boost_FIND_COMPONENTS error: https://stackoverflow.com/questions/62930429/c-avro-cmake-failed
RUN sed -i 's/cmake_minimum_required(VERSION 2.8)/cmake_minimum_required(VERSION 3.3)/g' /sources/orthanc-object-storage/Azure/CMakeLists.txt

RUN mkdir -p /build/cloud-storage/azure
WORKDIR /build/cloud-storage/azure

RUN cmake -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_TOOLCHAIN_FILE=/vcpkg/scripts/buildsystems/vcpkg.cmake -DORTHANC_FRAMEWORK_SOURCE=path -DORTHANC_FRAMEWORK_ROOT=/sources/orthanc/OrthancFramework/Sources /sources/orthanc-object-storage/Azure/
RUN make -j 4


########################## Orthanc Google storage plugins

FROM build-plugin-object-storage-google as build-google-object-storage

WORKDIR /

WORKDIR /sources
# CHANGE_VERSION_ORTHANC_CLOUD_STORAGE
RUN hg clone https://hg.orthanc-server.com/orthanc-object-storage/ -r 1.3.3

# CHANGE_VERSION_ORTHANC (framework version used to build the cloud storage plugins)
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
# CHANGE_VERSION_ORTHANC_CLOUD_STORAGE
RUN hg clone https://hg.orthanc-server.com/orthanc-object-storage/ -r 1.3.3

# CHANGE_VERSION_ORTHANC (framework version used to build the cloud storage plugins)
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

# CHANGE_VERSION_ORTHANC_EXPLORER_2
WORKDIR /sources

RUN git clone https://github.com/orthanc-server/orthanc-explorer-2.git && \
    cd /sources/orthanc-explorer-2 && \
	git checkout 5b20c3f07d4ae82ea79a69dba1a9d4173f0abef0

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


################################# the image that will run Orthanc dynamicaly linked
FROM orthanc-runner-base

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
COPY --from=build-plugin-auth /build/libOrthancAuthorization.so /usr/share/orthanc/plugins-available/
COPY --from=build-plugin-owv /build/libOrthancWebViewer.so /usr/share/orthanc/plugins-available/
COPY --from=build-plugin-python /build/libOrthancPython.so /usr/share/orthanc/plugins-available/
COPY --from=build-gdcm /build/libOrthancGdcm.so /usr/share/orthanc/plugins-available/
COPY --from=build-plugin-odbc /build/libOrthancOdbcIndex.so /usr/share/orthanc/plugins-available/
COPY --from=build-plugin-odbc /build/libOrthancOdbcStorage.so /usr/share/orthanc/plugins-available/
COPY --from=build-plugin-tcia /build/libOrthancTcia.so /usr/share/orthanc/plugins-available/
COPY --from=build-plugin-indexer /build/libOrthancIndexer.so /usr/share/orthanc/plugins-available/
COPY --from=build-stone-viewer /build/libStoneWebViewer.so /usr/share/orthanc/plugins-available/
COPY --from=build-oe2 /build/libOrthancExplorer2.so /usr/share/orthanc/plugins-available/

COPY --from=build-downloader /downloads/libOsimisWebViewer.so /usr/share/orthanc/plugins-available/
COPY --from=build-downloader /downloads/libOsimisWebViewerAlpha.so /usr/share/orthanc/plugins-available/

COPY --from=build-google-object-storage /build/cloud-storage/google/libOrthancGoogleCloudStorage.so /usr/share/orthanc/plugins-available/
COPY --from=build-azure-object-storage /build/cloud-storage/azure/libOrthancAzureBlobStorage.so /usr/share/orthanc/plugins-available/
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
