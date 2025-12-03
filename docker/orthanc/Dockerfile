ARG BASE_IMAGE_TAG=current
ARG STONE_INTERMEDIATE_TARGET=build-stone-viewer-amd64

FROM orthancteam/orthanc-builder-base:${BASE_IMAGE_TAG} AS orthanc-builder-base
ARG ARG_AWS_ACCESS_KEY_ID
ARG ARG_AWS_SECRET_ACCESS_KEY
ENV AWS_ACCESS_KEY_ID=$ARG_AWS_ACCESS_KEY_ID
ENV AWS_SECRET_ACCESS_KEY=$ARG_AWS_SECRET_ACCESS_KEY
ARG PREFER_DOWNLOADS=1
ARG ENABLE_UPLOAD=0
ARG PLATFORM=linux/amd64
ARG BASE_IMAGE_TAG=unknown
ARG STABLE_OR_UNSTABLE=stable


FROM jodogne/wasm-builder:3.1.49 AS wasm-builder-base-amd64

ARG ARG_AWS_ACCESS_KEY_ID
ARG ARG_AWS_SECRET_ACCESS_KEY
ENV AWS_ACCESS_KEY_ID=$ARG_AWS_ACCESS_KEY_ID
ENV AWS_SECRET_ACCESS_KEY=$ARG_AWS_SECRET_ACCESS_KEY
ARG PREFER_DOWNLOADS=1
ARG ENABLE_UPLOAD=0
ARG PLATFORM=linux/amd64
ARG BASE_IMAGE_TAG=unknown
ARG STABLE_OR_UNSTABLE=stable


RUN mkdir -p /.aws && echo region=eu-west-1 > /.aws/credentials
RUN DEBIAN_FRONTEND=noninteractive && apt-get --assume-yes update && apt-get -y --fix-broken install && DEBIAN_FRONTEND=noninteractive apt-get --assume-yes install curl awscli


FROM orthancteam/orthanc-runner-base:${BASE_IMAGE_TAG} AS orthanc-runner-base
# never add secrets in this image !!!!


FROM orthancteam/orthanc-builder-base:vcpkg-google-${BASE_IMAGE_TAG} AS build-plugin-object-storage-google
ARG ARG_AWS_ACCESS_KEY_ID
ARG ARG_AWS_SECRET_ACCESS_KEY
ENV AWS_ACCESS_KEY_ID=$ARG_AWS_ACCESS_KEY_ID
ENV AWS_SECRET_ACCESS_KEY=$ARG_AWS_SECRET_ACCESS_KEY
ARG PREFER_DOWNLOADS=1
ARG ENABLE_UPLOAD=0
ARG PLATFORM=linux/amd64
ARG BASE_IMAGE_TAG=unknown
ARG STABLE_OR_UNSTABLE=stable


FROM orthancteam/orthanc-builder-base:vcpkg-azure-${BASE_IMAGE_TAG} AS build-plugin-object-storage-azure
ARG ARG_AWS_ACCESS_KEY_ID
ARG ARG_AWS_SECRET_ACCESS_KEY
ENV AWS_ACCESS_KEY_ID=$ARG_AWS_ACCESS_KEY_ID
ENV AWS_SECRET_ACCESS_KEY=$ARG_AWS_SECRET_ACCESS_KEY
ARG PREFER_DOWNLOADS=1
ARG ENABLE_UPLOAD=0
ARG PLATFORM=linux/amd64
ARG BASE_IMAGE_TAG=unknown
ARG STABLE_OR_UNSTABLE=stable

########################## Orthanc

FROM orthanc-builder-base AS build-orthanc

ARG ORTHANC_COMMIT_ID
RUN /scripts/build-or-download.sh version=$STABLE_OR_UNSTABLE target=orthanc commitId=$ORTHANC_COMMIT_ID baseImage=$PLATFORM/$BASE_IMAGE_TAG preferDownloads=$PREFER_DOWNLOADS enableUploads=$ENABLE_UPLOAD

########################## Orthanc GDCM

FROM orthanc-builder-base AS build-gdcm

ARG ORTHANC_GDCM_COMMIT_ID
RUN /scripts/build-or-download.sh version=$STABLE_OR_UNSTABLE target=orthanc-gdcm commitId=$ORTHANC_GDCM_COMMIT_ID baseImage=$PLATFORM/$BASE_IMAGE_TAG preferDownloads=$PREFER_DOWNLOADS enableUploads=$ENABLE_UPLOAD

########################## Orthanc PG

FROM orthanc-builder-base AS build-plugin-pg

ARG ORTHANC_PG_COMMIT_ID
RUN /scripts/build-or-download.sh version=$STABLE_OR_UNSTABLE target=orthanc-pg commitId=$ORTHANC_PG_COMMIT_ID baseImage=$PLATFORM/$BASE_IMAGE_TAG preferDownloads=$PREFER_DOWNLOADS enableUploads=$ENABLE_UPLOAD

########################## Orthanc MySQL

FROM orthanc-builder-base AS build-plugin-mysql

ARG ORTHANC_MYSQL_COMMIT_ID
RUN /scripts/build-or-download.sh version=$STABLE_OR_UNSTABLE target=orthanc-mysql commitId=$ORTHANC_MYSQL_COMMIT_ID baseImage=$PLATFORM/$BASE_IMAGE_TAG preferDownloads=$PREFER_DOWNLOADS enableUploads=$ENABLE_UPLOAD

########################## Orthanc Transfers

FROM orthanc-builder-base AS build-plugin-transfers

ARG ORTHANC_TRANSFERS_COMMIT_ID
RUN /scripts/build-or-download.sh version=$STABLE_OR_UNSTABLE target=orthanc-transfers commitId=$ORTHANC_TRANSFERS_COMMIT_ID baseImage=$PLATFORM/$BASE_IMAGE_TAG preferDownloads=$PREFER_DOWNLOADS enableUploads=$ENABLE_UPLOAD

########################## Orthanc Dicomweb

FROM orthanc-builder-base AS build-plugin-dicomweb

ARG ORTHANC_DW_COMMIT_ID
RUN /scripts/build-or-download.sh version=$STABLE_OR_UNSTABLE target=orthanc-dicomweb commitId=$ORTHANC_DW_COMMIT_ID baseImage=$PLATFORM/$BASE_IMAGE_TAG preferDownloads=$PREFER_DOWNLOADS enableUploads=$ENABLE_UPLOAD

########################## Orthanc WSI

FROM orthanc-builder-base AS build-plugin-wsi

ARG ORTHANC_WSI_COMMIT_ID
RUN /scripts/build-or-download.sh version=$STABLE_OR_UNSTABLE target=orthanc-wsi commitId=$ORTHANC_WSI_COMMIT_ID baseImage=$PLATFORM/$BASE_IMAGE_TAG preferDownloads=$PREFER_DOWNLOADS enableUploads=$ENABLE_UPLOAD

RUN mkdir /downloads

# TODO: we should probably build these tools here as well
RUN wget https://orthanc.uclouvain.be/downloads/linux-standard-base/orthanc-wsi/3.3/OrthancWSIDicomToTiff --output-document /downloads/OrthancWSIDicomToTiff --quiet
RUN wget https://orthanc.uclouvain.be/downloads/linux-standard-base/orthanc-wsi/3.3/OrthancWSIDicomizer --output-document /downloads/OrthancWSIDicomizer --quiet

########################## Orthanc Webviewer

FROM orthanc-builder-base AS build-plugin-owv

ARG ORTHANC_OWV_COMMIT_ID
RUN /scripts/build-or-download.sh version=$STABLE_OR_UNSTABLE target=orthanc-webviewer commitId=$ORTHANC_OWV_COMMIT_ID baseImage=$PLATFORM/$BASE_IMAGE_TAG preferDownloads=$PREFER_DOWNLOADS enableUploads=$ENABLE_UPLOAD

########################## Orthanc authorization

FROM orthanc-builder-base AS build-plugin-auth

ARG ORTHANC_AUTH_COMMIT_ID
RUN /scripts/build-or-download.sh version=$STABLE_OR_UNSTABLE target=orthanc-authorization commitId=$ORTHANC_AUTH_COMMIT_ID baseImage=$PLATFORM/$BASE_IMAGE_TAG preferDownloads=$PREFER_DOWNLOADS enableUploads=$ENABLE_UPLOAD

########################## Orthanc Python

FROM orthanc-builder-base AS build-plugin-python

ARG ORTHANC_PYTHON_COMMIT_ID
RUN /scripts/build-or-download.sh version=$STABLE_OR_UNSTABLE target=orthanc-python commitId=$ORTHANC_PYTHON_COMMIT_ID baseImage=$PLATFORM/$BASE_IMAGE_TAG preferDownloads=$PREFER_DOWNLOADS enableUploads=$ENABLE_UPLOAD

########################## Orthanc ODBC

FROM orthanc-builder-base AS build-plugin-odbc

ARG ORTHANC_ODBC_COMMIT_ID
RUN /scripts/build-or-download.sh version=$STABLE_OR_UNSTABLE target=orthanc-odbc commitId=$ORTHANC_ODBC_COMMIT_ID baseImage=$PLATFORM/$BASE_IMAGE_TAG preferDownloads=$PREFER_DOWNLOADS enableUploads=$ENABLE_UPLOAD

# ########################## Orthanc Indexer

FROM orthanc-builder-base AS build-plugin-indexer

ARG ORTHANC_INDEXER_COMMIT_ID
RUN /scripts/build-or-download.sh version=$STABLE_OR_UNSTABLE target=orthanc-indexer commitId=$ORTHANC_INDEXER_COMMIT_ID baseImage=$PLATFORM/$BASE_IMAGE_TAG preferDownloads=$PREFER_DOWNLOADS enableUploads=$ENABLE_UPLOAD

########################## Orthanc Neuro

FROM orthanc-builder-base AS build-plugin-neuro

ARG ORTHANC_NEURO_COMMIT_ID
RUN /scripts/build-or-download.sh version=$STABLE_OR_UNSTABLE target=orthanc-neuro commitId=$ORTHANC_NEURO_COMMIT_ID baseImage=$PLATFORM/$BASE_IMAGE_TAG preferDownloads=$PREFER_DOWNLOADS enableUploads=$ENABLE_UPLOAD

########################## Orthanc STL

FROM orthanc-builder-base AS build-plugin-stl

ARG ORTHANC_STL_COMMIT_ID
RUN /scripts/build-or-download.sh version=$STABLE_OR_UNSTABLE target=orthanc-stl commitId=$ORTHANC_STL_COMMIT_ID baseImage=$PLATFORM/$BASE_IMAGE_TAG preferDownloads=$PREFER_DOWNLOADS enableUploads=$ENABLE_UPLOAD

########################## Orthanc TCIA

FROM orthanc-builder-base AS build-plugin-tcia

ARG ORTHANC_TCIA_COMMIT_ID
RUN /scripts/build-or-download.sh version=$STABLE_OR_UNSTABLE target=orthanc-tcia commitId=$ORTHANC_TCIA_COMMIT_ID baseImage=$PLATFORM/$BASE_IMAGE_TAG preferDownloads=$PREFER_DOWNLOADS enableUploads=$ENABLE_UPLOAD

########################## Orthanc Java

FROM orthanc-builder-base AS build-plugin-java

ARG ORTHANC_JAVA_COMMIT_ID
RUN /scripts/build-or-download.sh version=$STABLE_OR_UNSTABLE target=orthanc-java commitId=$ORTHANC_JAVA_COMMIT_ID baseImage=$PLATFORM/$BASE_IMAGE_TAG preferDownloads=$PREFER_DOWNLOADS enableUploads=$ENABLE_UPLOAD

########################## Orthanc Education

FROM orthanc-builder-base AS build-plugin-education

ARG ORTHANC_EDUCATION_COMMIT_ID
RUN /scripts/build-or-download.sh version=$STABLE_OR_UNSTABLE target=orthanc-education commitId=$ORTHANC_EDUCATION_COMMIT_ID baseImage=$PLATFORM/$BASE_IMAGE_TAG preferDownloads=$PREFER_DOWNLOADS enableUploads=$ENABLE_UPLOAD

########################## Advanced Storage

FROM orthanc-builder-base AS build-plugin-advanced-storage

ARG ORTHANC_ADVANCED_STORAGE_COMMIT_ID
RUN /scripts/build-or-download.sh version=$STABLE_OR_UNSTABLE target=orthanc-advanced-storage commitId=$ORTHANC_ADVANCED_STORAGE_COMMIT_ID baseImage=$PLATFORM/$BASE_IMAGE_TAG preferDownloads=$PREFER_DOWNLOADS enableUploads=$ENABLE_UPLOAD

########################## Worklists

FROM orthanc-builder-base AS build-plugin-worklists

ARG ORTHANC_WORKLISTS_COMMIT_ID
RUN /scripts/build-or-download.sh version=$STABLE_OR_UNSTABLE target=orthanc-worklists commitId=$ORTHANC_WORKLISTS_COMMIT_ID baseImage=$PLATFORM/$BASE_IMAGE_TAG preferDownloads=$PREFER_DOWNLOADS enableUploads=$ENABLE_UPLOAD

########################## Stone Web Viewer

FROM wasm-builder-base-amd64 AS build-wasm-stone-viewer-amd64

COPY --from=orthanc-builder-base /scripts/build-or-download.sh /scripts/

RUN ls -al /
# RUN env
RUN ls -al /scripts
ARG ORTHANC_STONE_VIEWER_COMMIT_ID
RUN /scripts/build-or-download.sh version=$STABLE_OR_UNSTABLE target=orthanc-stone-wasm commitId=$ORTHANC_STONE_VIEWER_COMMIT_ID baseImage=$PLATFORM/$BASE_IMAGE_TAG preferDownloads=$PREFER_DOWNLOADS enableUploads=$ENABLE_UPLOAD
RUN ls -al /target


FROM orthanc-builder-base AS build-stone-viewer-amd64

ARG ORTHANC_STONE_VIEWER_COMMIT_ID

RUN mkdir -p /downloads/wasm-binaries/StoneWebViewer
COPY --from=build-wasm-stone-viewer-amd64 /target/StoneWebViewer/ /downloads/wasm-binaries/StoneWebViewer
RUN ls -al /downloads/wasm-binaries/StoneWebViewer

RUN /scripts/build-or-download.sh version=$STABLE_OR_UNSTABLE target=orthanc-stone-so commitId=$ORTHANC_STONE_VIEWER_COMMIT_ID baseImage=$PLATFORM/$BASE_IMAGE_TAG preferDownloads=$PREFER_DOWNLOADS enableUploads=$ENABLE_UPLOAD

FROM orthanc-builder-base AS download-wasm-stone-viewer-arm64

RUN ls -al /
# RUN env
RUN ls -al /scripts
ARG ORTHANC_STONE_VIEWER_COMMIT_ID
# when building for arm64, simply download the WASM build that has been published by CI when building the linux/amd64 platform
RUN /scripts/build-or-download.sh version=$STABLE_OR_UNSTABLE target=download-orthanc-stone-wasm commitId=$ORTHANC_STONE_VIEWER_COMMIT_ID baseImage=linux/amd64/$BASE_IMAGE_TAG preferDownloads=$PREFER_DOWNLOADS enableUploads=0
RUN ls -al /target



FROM orthanc-builder-base AS build-stone-viewer-arm64

ARG ORTHANC_STONE_VIEWER_COMMIT_ID

RUN mkdir -p /downloads/wasm-binaries/StoneWebViewer
COPY --from=download-wasm-stone-viewer-arm64 /target/StoneWebViewer/ /downloads/wasm-binaries/StoneWebViewer
RUN ls -al /downloads/wasm-binaries/StoneWebViewer

RUN /scripts/build-or-download.sh version=$STABLE_OR_UNSTABLE target=orthanc-stone-so commitId=$ORTHANC_STONE_VIEWER_COMMIT_ID baseImage=$PLATFORM/$BASE_IMAGE_TAG preferDownloads=$PREFER_DOWNLOADS enableUploads=$ENABLE_UPLOAD

# we need a final unique target name for the later copy --from=build-stone-viewer (copy can not use a variable)
FROM ${STONE_INTERMEDIATE_TARGET} AS build-stone-viewer

########################## Orthanc azure storage plugins

FROM build-plugin-object-storage-azure AS build-azure-object-storage

ARG ORTHANC_AZURE_STORAGE_COMMIT_ID
RUN /scripts/build-or-download.sh version=$STABLE_OR_UNSTABLE target=orthanc-azure-storage commitId=$ORTHANC_AZURE_STORAGE_COMMIT_ID baseImage=$PLATFORM/$BASE_IMAGE_TAG preferDownloads=$PREFER_DOWNLOADS enableUploads=$ENABLE_UPLOAD

########################## Orthanc Google storage plugins

FROM build-plugin-object-storage-google AS build-google-object-storage

ARG ORTHANC_GOOGLE_STORAGE_COMMIT_ID
RUN /scripts/build-or-download.sh version=$STABLE_OR_UNSTABLE target=orthanc-google-storage commitId=$ORTHANC_GOOGLE_STORAGE_COMMIT_ID baseImage=$PLATFORM/$BASE_IMAGE_TAG preferDownloads=$PREFER_DOWNLOADS enableUploads=$ENABLE_UPLOAD

########################## Orthanc s3 object storage plugins

FROM orthanc-builder-base AS build-s3-object-storage

ARG ORTHANC_AWS_STORAGE_COMMIT_ID
RUN /scripts/build-or-download.sh version=$STABLE_OR_UNSTABLE target=orthanc-s3 commitId=$ORTHANC_AWS_STORAGE_COMMIT_ID baseImage=$PLATFORM/$BASE_IMAGE_TAG preferDownloads=$PREFER_DOWNLOADS enableUploads=$ENABLE_UPLOAD

########################## Orthanc Explorer 2

FROM orthanc-builder-base AS build-oe2

ARG ORTHANC_OE2_COMMIT_ID
ARG ORTHANC_OE2_VERSION
RUN /scripts/build-or-download.sh version=$STABLE_OR_UNSTABLE target=orthanc-explorer-2 commitId=$ORTHANC_OE2_COMMIT_ID extraArg1=$ORTHANC_OE2_VERSION baseImage=$PLATFORM/$BASE_IMAGE_TAG preferDownloads=$PREFER_DOWNLOADS enableUploads=$ENABLE_UPLOAD

########################## Kitware's VolView for Orthanc

FROM orthanc-builder-base AS build-plugin-volview

ARG ORTHANC_VOLVIEW_COMMIT_ID
RUN if [ "$PLATFORM" = "linux/amd64" ]; then /scripts/build-or-download.sh version=$STABLE_OR_UNSTABLE target=orthanc-volview commitId=$ORTHANC_VOLVIEW_COMMIT_ID baseImage=$PLATFORM/$BASE_IMAGE_TAG preferDownloads=$PREFER_DOWNLOADS enableUploads=$ENABLE_UPLOAD; fi
# when building for arm64, simply download the WEB build that has been published by CI when building the linux/amd64 platform
RUN if [ "$PLATFORM" = "linux/arm64" ]; then /scripts/build-or-download.sh version=$STABLE_OR_UNSTABLE target=download-orthanc-volview-dist commitId=$ORTHANC_VOLVIEW_COMMIT_ID baseImage=linux/amd64/$BASE_IMAGE_TAG preferDownloads=$PREFER_DOWNLOADS enableUploads=0; fi
RUN if [ "$PLATFORM" = "linux/arm64" ]; then /scripts/build-or-download.sh version=$STABLE_OR_UNSTABLE target=orthanc-volview-from-dist commitId=$ORTHANC_VOLVIEW_COMMIT_ID baseImage=linux/arm64/$BASE_IMAGE_TAG preferDownloads=$PREFER_DOWNLOADS enableUploads=$ENABLE_UPLOAD; fi


########################## OHIF for Orthanc

FROM orthanc-builder-base AS build-plugin-ohif

ARG ORTHANC_OHIF_COMMIT_ID
RUN if [ "$PLATFORM" = "linux/amd64" ]; then /scripts/build-or-download.sh version=$STABLE_OR_UNSTABLE target=orthanc-ohif commitId=$ORTHANC_OHIF_COMMIT_ID baseImage=$PLATFORM/$BASE_IMAGE_TAG preferDownloads=$PREFER_DOWNLOADS enableUploads=$ENABLE_UPLOAD; fi
# when building for arm64, simply download the WEB build that has been published by CI when building the linux/amd64 platform
RUN if [ "$PLATFORM" = "linux/arm64" ]; then /scripts/build-or-download.sh version=$STABLE_OR_UNSTABLE target=download-orthanc-ohif-dist commitId=$ORTHANC_OHIF_COMMIT_ID baseImage=linux/amd64/$BASE_IMAGE_TAG preferDownloads=$PREFER_DOWNLOADS enableUploads=0; fi
RUN if [ "$PLATFORM" = "linux/arm64" ]; then /scripts/build-or-download.sh version=$STABLE_OR_UNSTABLE target=orthanc-ohif-from-dist commitId=$ORTHANC_OHIF_COMMIT_ID baseImage=linux/arm64/$BASE_IMAGE_TAG preferDownloads=$PREFER_DOWNLOADS enableUploads=$ENABLE_UPLOAD; fi

########################## Orthanc downloads (since wget is not in the runner image)

FROM orthanc-builder-base AS build-downloader

RUN mkdir /downloads
# CHANGE_VERSION_WVB (LSB are still built by Jenkins because jenkins is also building the frontend)
RUN wget https://orthanc.uclouvain.be/downloads/linux-standard-base/osimis-web-viewer/1.4.3/libOsimisWebViewer.so --output-document /downloads/libOsimisWebViewer.so --quiet
# CHANGE_VERSION_WVB_ALPHA
RUN wget https://orthanc.uclouvain.be/downloads/linux-standard-base/osimis-web-viewer/1.4.3/libOsimisWebViewer.so --output-document /downloads/libOsimisWebViewerAlpha.so --quiet



################################# the image that will run Orthanc dynamicaly linked (intermediate version without vcpkg builds)
FROM orthanc-runner-base AS orthanc-no-vcpkg

# always create an 'orthanc' group (gid=999) and an orthanc user (uid=999)
# and grants him all permissions on files that can be modified by the docker-entrypoint.sh
# The default root users can still access these files too.
# for the /etc/hostid -> we must make sure the file exists to grant the permission
RUN groupadd --system orthanc --gid=999; \
    useradd --system --gid=orthanc --uid=999 --home-dir=/var/lib/orthanc --shell=/bin/false orthanc;

RUN mkdir -p /etc/orthanc && \
      mkdir -p /usr/share/orthanc/plugins-available && \
      ln --symbolic /usr/share/orthanc/plugins-available /usr/share/orthanc/plugins-disabled && \
      echo "plugins-disabled is deprecated, please source plugins from plugins-available instead" >/usr/share/orthanc/plugins-disabled.README && \
      mkdir -p /usr/share/orthanc/plugins/ && \
      mkdir -p /var/lib/orthanc; \
      chown -R orthanc:orthanc /var/lib/orthanc; \
      chown -R orthanc:orthanc /tmp; \
      chown -R orthanc:orthanc /usr/share/orthanc/plugins; \
      chown -R orthanc:orthanc /usr/share/orthanc/plugins-available; \
      echo not-generated > /etc/hostid; \
      chown orthanc:orthanc /etc/hostid

COPY --from=build-orthanc --chown=orthanc:orthanc --chmod=755 /build/Orthanc /usr/local/bin/
COPY --from=build-orthanc --chown=orthanc:orthanc --chmod=755 /build/libServeFolders.so /usr/share/orthanc/plugins-available/
COPY --from=build-orthanc --chown=orthanc:orthanc --chmod=755 /build/libHousekeeper.so /usr/share/orthanc/plugins-available/
COPY --from=build-orthanc --chown=orthanc:orthanc --chmod=755 /build/libConnectivityChecks.so /usr/share/orthanc/plugins-available/
COPY --from=build-orthanc --chown=orthanc:orthanc --chmod=755 /build/libDelayedDeletion.so /usr/share/orthanc/plugins-available/
COPY --from=build-orthanc --chown=orthanc:orthanc --chmod=755 /build/libMultitenantDicom.so /usr/share/orthanc/plugins-available/
# RUN ldd /usr/bin/Orthanc

COPY --from=build-plugin-pg --chown=orthanc:orthanc --chmod=755 /build/libOrthancPostgreSQLIndex.so /usr/share/orthanc/plugins-available/
COPY --from=build-plugin-pg --chown=orthanc:orthanc --chmod=755 /build/libOrthancPostgreSQLStorage.so /usr/share/orthanc/plugins-available/
COPY --from=build-plugin-mysql --chown=orthanc:orthanc --chmod=755 /build/libOrthancMySQLIndex.so /usr/share/orthanc/plugins-available/
COPY --from=build-plugin-mysql --chown=orthanc:orthanc --chmod=755 /build/libOrthancMySQLStorage.so /usr/share/orthanc/plugins-available/
COPY --from=build-plugin-transfers --chown=orthanc:orthanc --chmod=755 /build/libOrthancTransfers.so /usr/share/orthanc/plugins-available/
COPY --from=build-plugin-dicomweb --chown=orthanc:orthanc --chmod=755 /build/libOrthancDicomWeb.so /usr/share/orthanc/plugins-available/
COPY --from=build-plugin-wsi --chown=orthanc:orthanc --chmod=755 /build/libOrthancWSI.so /usr/share/orthanc/plugins-available/
COPY --from=build-plugin-wsi --chown=orthanc:orthanc --chmod=755 /downloads/OrthancWSIDicomToTiff /usr/local/bin/
COPY --from=build-plugin-wsi --chown=orthanc:orthanc --chmod=755 /downloads/OrthancWSIDicomizer /usr/local/bin/
COPY --from=build-plugin-auth --chown=orthanc:orthanc --chmod=755 /build/libOrthancAuthorization.so /usr/share/orthanc/plugins-available/
COPY --from=build-plugin-owv --chown=orthanc:orthanc --chmod=755 /build/libOrthancWebViewer.so /usr/share/orthanc/plugins-available/
COPY --from=build-plugin-python --chown=orthanc:orthanc --chmod=755 /build/libOrthancPython.so /usr/share/orthanc/plugins-available/
COPY --from=build-gdcm --chown=orthanc:orthanc --chmod=755 /build/libOrthancGdcm.so /usr/share/orthanc/plugins-available/
COPY --from=build-plugin-odbc --chown=orthanc:orthanc --chmod=755 /build/libOrthancOdbcIndex.so /usr/share/orthanc/plugins-available/
COPY --from=build-plugin-odbc --chown=orthanc:orthanc --chmod=755 /build/libOrthancOdbcStorage.so /usr/share/orthanc/plugins-available/
COPY --from=build-plugin-tcia --chown=orthanc:orthanc --chmod=755 /build/libOrthancTcia.so /usr/share/orthanc/plugins-available/
COPY --from=build-plugin-indexer --chown=orthanc:orthanc --chmod=755 /build/libOrthancIndexer.so /usr/share/orthanc/plugins-available/
COPY --from=build-plugin-neuro --chown=orthanc:orthanc --chmod=755 /build/libOrthancNeuro.so /usr/share/orthanc/plugins-available/
COPY --from=build-stone-viewer --chown=orthanc:orthanc --chmod=755 /build/libStoneWebViewer.so /usr/share/orthanc/plugins-available/
COPY --from=build-oe2 --chown=orthanc:orthanc --chmod=755 /build/libOrthancExplorer2.so /usr/share/orthanc/plugins-available/
COPY --from=build-plugin-volview --chown=orthanc:orthanc --chmod=755 /build/libOrthancVolView.so /usr/share/orthanc/plugins-available/
COPY --from=build-plugin-ohif --chown=orthanc:orthanc --chmod=755 /build/libOrthancOHIF.so /usr/share/orthanc/plugins-available/
COPY --from=build-plugin-stl --chown=orthanc:orthanc --chmod=755 /build/libOrthancSTL.so /usr/share/orthanc/plugins-available/
COPY --from=build-plugin-advanced-storage --chown=orthanc:orthanc --chmod=755 /build/libAdvancedStorage.so /usr/share/orthanc/plugins-available/
COPY --from=build-plugin-worklists --chown=orthanc:orthanc --chmod=755 /build/libOrthancWorklists.so /usr/share/orthanc/plugins-available/
COPY --from=build-plugin-education --chown=orthanc:orthanc --chmod=755 /build/libOrthancEducation.so /usr/share/orthanc/plugins-available/

COPY --from=build-downloader --chown=orthanc:orthanc --chmod=755 /downloads/libOsimisWebViewer.so /usr/share/orthanc/plugins-available/
COPY --from=build-downloader --chown=orthanc:orthanc --chmod=755 /downloads/libOsimisWebViewerAlpha.so /usr/share/orthanc/plugins-available/

COPY --from=build-s3-object-storage --chown=orthanc:orthanc --chmod=755 /build/libOrthancAwsS3Storage.so /usr/share/orthanc/plugins-available/

# If the target architecture is not AMD64, then delete the OsimisWebViewer &
# OsimisWebViewerAlpha plugin as they are only compatible with AMD64 builds
RUN if [[ ! -z "$PLATFORM" ]] && [[ "$PLATFORM" != "linux/amd64" ]]; then \
	rm /usr/share/orthanc/plugins-available/libOsimisWebViewer.so && \
	rm /usr/share/orthanc/plugins-available/libOsimisWebViewerAlpha.so; \
	fi

# RUN chmod +x /usr/share/orthanc/plugins-available/*
# RUN chmod +x /usr/local/bin/*

RUN pip install envsubst==0.1.5 --break-system-packages

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
RUN apt purge --assume-yes build-essential perl bzip2 gnupg xdg-user-dirs && apt --assume-yes autoremove



################################# the "full" image that will run Orthanc dynamicaly linked (final version with vcpkg builds and Microsoft unixodbc)
FROM orthanc-no-vcpkg AS orthanc-with-vcpkg

# When installing JAVA; the --no-install-recommends prevent installation of systemd which would create a groupid 999 conflicting with the orthanc one

RUN export DEBIAN_FRONTEND=noninteractive && \
  apt-get --assume-yes update && \
  apt-get --assume-yes install curl gnupg2 && \
  apt-get --assume-yes install default-jdk  --no-install-recommends && \
  apt-get --assume-yes clean && \
  rm --recursive --force /var/lib/apt/lists/*

RUN mkdir /java

RUN curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg
RUN curl https://packages.microsoft.com/config/debian/12/prod.list > /etc/apt/sources.list.d/mssql-release.list


RUN apt-get update && \
    ACCEPT_EULA=Y apt-get install -y msodbcsql18 unixodbc-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY --from=build-google-object-storage --chown=orthanc:orthanc --chmod=775 /build/libOrthancGoogleCloudStorage.so /usr/share/orthanc/plugins-available/
COPY --from=build-azure-object-storage --chown=orthanc:orthanc --chmod=775 /build/libOrthancAzureBlobStorage.so /usr/share/orthanc/plugins-available/
COPY --from=build-plugin-java --chown=orthanc:orthanc --chmod=775 /build/libOrthancJava.so /usr/share/orthanc/plugins-available/
COPY --from=build-plugin-java --chown=orthanc:orthanc --chmod=775 /build/OrthancJavaSDK.jar /java
