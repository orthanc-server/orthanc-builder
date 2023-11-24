ARG BASE_IMAGE_TAG=current

FROM osimis/orthanc-builder-base:${BASE_IMAGE_TAG} as orthanc-builder-base
ARG ARG_AWS_ACCESS_KEY_ID
ARG ARG_AWS_SECRET_ACCESS_KEY
ENV AWS_ACCESS_KEY_ID=$ARG_AWS_ACCESS_KEY_ID
ENV AWS_SECRET_ACCESS_KEY=$ARG_AWS_SECRET_ACCESS_KEY
ARG PREFER_DOWNLOADS=1
ARG ENABLE_UPLOAD=0
ARG PLATFORM=linux/amd64
ARG BASE_IMAGE_TAG=unknown
ARG STABLE_OR_UNSTABLE=stable


FROM jodogne/wasm-builder:2.0.23 as wasm-builder-base
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


FROM osimis/orthanc-runner-base:${BASE_IMAGE_TAG} as orthanc-runner-base
# never add secrets in this image !!!!


FROM osimis/orthanc-builder-base:vcpkg-google-${BASE_IMAGE_TAG} as build-plugin-object-storage-google
ARG ARG_AWS_ACCESS_KEY_ID
ARG ARG_AWS_SECRET_ACCESS_KEY
ENV AWS_ACCESS_KEY_ID=$ARG_AWS_ACCESS_KEY_ID
ENV AWS_SECRET_ACCESS_KEY=$ARG_AWS_SECRET_ACCESS_KEY
ARG PREFER_DOWNLOADS=1
ARG ENABLE_UPLOAD=0
ARG PLATFORM=linux/amd64
ARG BASE_IMAGE_TAG=unknown
ARG STABLE_OR_UNSTABLE=stable


FROM osimis/orthanc-builder-base:vcpkg-azure-${BASE_IMAGE_TAG} as build-plugin-object-storage-azure
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

FROM orthanc-builder-base as build-orthanc

ARG ORTHANC_COMMIT_ID
RUN /scripts/build-or-download.sh version=$STABLE_OR_UNSTABLE target=orthanc commitId=$ORTHANC_COMMIT_ID baseImage=$PLATFORM/$BASE_IMAGE_TAG preferDownloads=$PREFER_DOWNLOADS enableUploads=$ENABLE_UPLOAD

########################## Orthanc GDCM

FROM orthanc-builder-base as build-gdcm

ARG ORTHANC_GDCM_COMMIT_ID
RUN /scripts/build-or-download.sh version=$STABLE_OR_UNSTABLE target=orthanc-gdcm commitId=$ORTHANC_GDCM_COMMIT_ID baseImage=$PLATFORM/$BASE_IMAGE_TAG preferDownloads=$PREFER_DOWNLOADS enableUploads=$ENABLE_UPLOAD

########################## Orthanc PG

FROM orthanc-builder-base as build-plugin-pg

ARG ORTHANC_PG_COMMIT_ID
RUN /scripts/build-or-download.sh version=$STABLE_OR_UNSTABLE target=orthanc-pg commitId=$ORTHANC_PG_COMMIT_ID baseImage=$PLATFORM/$BASE_IMAGE_TAG preferDownloads=$PREFER_DOWNLOADS enableUploads=$ENABLE_UPLOAD

########################## Orthanc MySQL

FROM orthanc-builder-base as build-plugin-mysql

ARG ORTHANC_MYSQL_COMMIT_ID
RUN /scripts/build-or-download.sh version=$STABLE_OR_UNSTABLE target=orthanc-mysql commitId=$ORTHANC_MYSQL_COMMIT_ID baseImage=$PLATFORM/$BASE_IMAGE_TAG preferDownloads=$PREFER_DOWNLOADS enableUploads=$ENABLE_UPLOAD

########################## Orthanc Transfers

FROM orthanc-builder-base as build-plugin-transfers

ARG ORTHANC_TRANSFERS_COMMIT_ID
RUN /scripts/build-or-download.sh version=$STABLE_OR_UNSTABLE target=orthanc-transfers commitId=$ORTHANC_TRANSFERS_COMMIT_ID baseImage=$PLATFORM/$BASE_IMAGE_TAG preferDownloads=$PREFER_DOWNLOADS enableUploads=$ENABLE_UPLOAD

########################## Orthanc Dicomweb

FROM orthanc-builder-base as build-plugin-dicomweb

ARG ORTHANC_DW_COMMIT_ID
RUN /scripts/build-or-download.sh version=$STABLE_OR_UNSTABLE target=orthanc-dicomweb commitId=$ORTHANC_DW_COMMIT_ID baseImage=$PLATFORM/$BASE_IMAGE_TAG preferDownloads=$PREFER_DOWNLOADS enableUploads=$ENABLE_UPLOAD

########################## Orthanc WSI

FROM orthanc-builder-base as build-plugin-wsi

ARG ORTHANC_WSI_COMMIT_ID
RUN /scripts/build-or-download.sh version=$STABLE_OR_UNSTABLE target=orthanc-wsi commitId=$ORTHANC_WSI_COMMIT_ID baseImage=$PLATFORM/$BASE_IMAGE_TAG preferDownloads=$PREFER_DOWNLOADS enableUploads=$ENABLE_UPLOAD

RUN mkdir /downloads

# TODO: we should probably build these tools here as well
RUN wget https://orthanc.uclouvain.be/downloads/linux-standard-base/orthanc-wsi/2.0/OrthancWSIDicomToTiff --output-document /downloads/OrthancWSIDicomToTiff --quiet
RUN wget https://orthanc.uclouvain.be/downloads/linux-standard-base/orthanc-wsi/2.0/OrthancWSIDicomizer --output-document /downloads/OrthancWSIDicomizer --quiet

########################## Orthanc Webviewer

FROM orthanc-builder-base as build-plugin-owv

ARG ORTHANC_OWV_COMMIT_ID
RUN /scripts/build-or-download.sh version=$STABLE_OR_UNSTABLE target=orthanc-webviewer commitId=$ORTHANC_OWV_COMMIT_ID baseImage=$PLATFORM/$BASE_IMAGE_TAG preferDownloads=$PREFER_DOWNLOADS enableUploads=$ENABLE_UPLOAD

########################## Orthanc authorization

FROM orthanc-builder-base as build-plugin-auth

ARG ORTHANC_AUTH_COMMIT_ID
RUN /scripts/build-or-download.sh version=$STABLE_OR_UNSTABLE target=orthanc-authorization commitId=$ORTHANC_AUTH_COMMIT_ID baseImage=$PLATFORM/$BASE_IMAGE_TAG preferDownloads=$PREFER_DOWNLOADS enableUploads=$ENABLE_UPLOAD

########################## Orthanc Python

FROM orthanc-builder-base as build-plugin-python

ARG ORTHANC_PYTHON_COMMIT_ID
RUN /scripts/build-or-download.sh version=$STABLE_OR_UNSTABLE target=orthanc-python commitId=$ORTHANC_PYTHON_COMMIT_ID baseImage=$PLATFORM/$BASE_IMAGE_TAG preferDownloads=$PREFER_DOWNLOADS enableUploads=$ENABLE_UPLOAD

########################## Orthanc ODBC

FROM orthanc-builder-base as build-plugin-odbc

ARG ORTHANC_ODBC_COMMIT_ID
RUN /scripts/build-or-download.sh version=$STABLE_OR_UNSTABLE target=orthanc-odbc commitId=$ORTHANC_ODBC_COMMIT_ID baseImage=$PLATFORM/$BASE_IMAGE_TAG preferDownloads=$PREFER_DOWNLOADS enableUploads=$ENABLE_UPLOAD

# ########################## Orthanc Indexer

FROM orthanc-builder-base as build-plugin-indexer

ARG ORTHANC_INDEXER_COMMIT_ID
RUN /scripts/build-or-download.sh version=$STABLE_OR_UNSTABLE target=orthanc-indexer commitId=$ORTHANC_INDEXER_COMMIT_ID baseImage=$PLATFORM/$BASE_IMAGE_TAG preferDownloads=$PREFER_DOWNLOADS enableUploads=$ENABLE_UPLOAD

########################## Orthanc Neuro

FROM orthanc-builder-base as build-plugin-neuro

ARG ORTHANC_NEURO_COMMIT_ID
RUN /scripts/build-or-download.sh version=$STABLE_OR_UNSTABLE target=orthanc-neuro commitId=$ORTHANC_NEURO_COMMIT_ID baseImage=$PLATFORM/$BASE_IMAGE_TAG preferDownloads=$PREFER_DOWNLOADS enableUploads=$ENABLE_UPLOAD

########################## Orthanc TCIA

FROM orthanc-builder-base as build-plugin-tcia

ARG ORTHANC_TCIA_COMMIT_ID
RUN /scripts/build-or-download.sh version=$STABLE_OR_UNSTABLE target=orthanc-tcia commitId=$ORTHANC_TCIA_COMMIT_ID baseImage=$PLATFORM/$BASE_IMAGE_TAG preferDownloads=$PREFER_DOWNLOADS enableUploads=$ENABLE_UPLOAD

########################## Stone Web Viewer

FROM wasm-builder-base as build-wasm-stone-viewer


COPY --from=orthanc-builder-base /scripts/build-or-download.sh /scripts/

RUN ls -al /
RUN env
RUN ls -al /scripts
ARG ORTHANC_STONE_VIEWER_COMMIT_ID
RUN /scripts/build-or-download.sh version=$STABLE_OR_UNSTABLE target=orthanc-stone-wasm commitId=$ORTHANC_STONE_VIEWER_COMMIT_ID baseImage=$PLATFORM/$BASE_IMAGE_TAG preferDownloads=$PREFER_DOWNLOADS enableUploads=$ENABLE_UPLOAD




FROM orthanc-builder-base as build-stone-viewer

ARG ORTHANC_STONE_VIEWER_COMMIT_ID

RUN mkdir -p /downloads/wasm-binaries/StoneWebViewer
COPY --from=build-wasm-stone-viewer /target/StoneWebViewer/ /downloads/wasm-binaries/StoneWebViewer
RUN ls -al /downloads/wasm-binaries/StoneWebViewer

RUN /scripts/build-or-download.sh version=$STABLE_OR_UNSTABLE target=orthanc-stone-so commitId=$ORTHANC_STONE_VIEWER_COMMIT_ID baseImage=$PLATFORM/$BASE_IMAGE_TAG preferDownloads=$PREFER_DOWNLOADS enableUploads=$ENABLE_UPLOAD



########################## Orthanc azure storage plugins

FROM build-plugin-object-storage-azure as build-azure-object-storage

ARG ORTHANC_AZURE_STORAGE_COMMIT_ID
RUN /scripts/build-or-download.sh version=$STABLE_OR_UNSTABLE target=orthanc-azure-storage commitId=$ORTHANC_AZURE_STORAGE_COMMIT_ID baseImage=$PLATFORM/$BASE_IMAGE_TAG preferDownloads=$PREFER_DOWNLOADS enableUploads=$ENABLE_UPLOAD

########################## Orthanc Google storage plugins

FROM build-plugin-object-storage-google as build-google-object-storage

ARG ORTHANC_GOOGLE_STORAGE_COMMIT_ID
RUN /scripts/build-or-download.sh version=$STABLE_OR_UNSTABLE target=orthanc-google-storage commitId=$ORTHANC_GOOGLE_STORAGE_COMMIT_ID baseImage=$PLATFORM/$BASE_IMAGE_TAG preferDownloads=$PREFER_DOWNLOADS enableUploads=$ENABLE_UPLOAD

########################## Orthanc s3 object storage plugins

FROM orthanc-builder-base as build-s3-object-storage

ARG ORTHANC_AWS_STORAGE_COMMIT_ID
RUN /scripts/build-or-download.sh version=$STABLE_OR_UNSTABLE target=orthanc-s3 commitId=$ORTHANC_AWS_STORAGE_COMMIT_ID baseImage=$PLATFORM/$BASE_IMAGE_TAG preferDownloads=$PREFER_DOWNLOADS enableUploads=$ENABLE_UPLOAD

########################## Orthanc Explorer 2

FROM orthanc-builder-base as build-oe2

ARG ORTHANC_OE2_COMMIT_ID
ARG ORTHANC_OE2_VERSION
RUN /scripts/build-or-download.sh version=$STABLE_OR_UNSTABLE target=orthanc-explorer-2 commitId=$ORTHANC_OE2_COMMIT_ID extraArg1=$ORTHANC_OE2_VERSION baseImage=$PLATFORM/$BASE_IMAGE_TAG preferDownloads=$PREFER_DOWNLOADS enableUploads=$ENABLE_UPLOAD

########################## Kitware's VolView for Orthanc

FROM orthanc-builder-base as build-plugin-volview

ARG ORTHANC_VOLVIEW_COMMIT_ID
# CHANGE_VERSION_VOLVIEW check version in https://orthanc.uclouvain.be/hg/orthanc-volview/file/tip/Resources/CreateVolViewDist.sh
ARG VOLVIEW_VERSION=4.1.1
RUN /scripts/build-or-download.sh version=$STABLE_OR_UNSTABLE target=orthanc-volview commitId=$ORTHANC_VOLVIEW_COMMIT_ID extraArg1=$VOLVIEW_VERSION baseImage=$PLATFORM/$BASE_IMAGE_TAG preferDownloads=$PREFER_DOWNLOADS enableUploads=$ENABLE_UPLOAD

########################## OHIF for Orthanc

FROM orthanc-builder-base as build-plugin-ohif

ARG ORTHANC_OHIF_COMMIT_ID
# CHANGE_VERSION_OHIF check version in https://orthanc.uclouvain.be/hg/orthanc-ohif/file/tip/Resources/CreateOHIFDist.sh
ARG OHIF_VERSION=3.7.0
RUN /scripts/build-or-download.sh version=$STABLE_OR_UNSTABLE target=orthanc-ohif commitId=$ORTHANC_OHIF_COMMIT_ID extraArg1=$OHIF_VERSION baseImage=$PLATFORM/$BASE_IMAGE_TAG preferDownloads=$PREFER_DOWNLOADS enableUploads=$ENABLE_UPLOAD

########################## Orthanc downloads (since wget is not in the runner image)

FROM orthanc-builder-base as build-downloader

RUN mkdir /downloads

# CHANGE_VERSION_WVB (LSB are still built by Jenkins because jenkins is also building the frontend)
RUN wget https://orthanc.uclouvain.be/downloads/linux-standard-base/osimis-web-viewer/1.4.2/libOsimisWebViewer.so --output-document /downloads/libOsimisWebViewer.so --quiet
# CHANGE_VERSION_WVB_ALPHA
RUN wget https://orthanc.uclouvain.be/downloads/linux-standard-base/osimis-web-viewer/1.4.2/libOsimisWebViewer.so --output-document /downloads/libOsimisWebViewerAlpha.so --quiet


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
COPY --from=build-orthanc /build/libHousekeeper.so /usr/share/orthanc/plugins-available/
COPY --from=build-orthanc /build/libConnectivityChecks.so /usr/share/orthanc/plugins-available/
COPY --from=build-orthanc /build/libDelayedDeletion.so /usr/share/orthanc/plugins-available/
COPY --from=build-orthanc /build/libMultitenantDicom.so /usr/share/orthanc/plugins-available/
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
COPY --from=build-plugin-volview /build/libOrthancVolView.so /usr/share/orthanc/plugins-available/
COPY --from=build-plugin-ohif /build/libOrthancOHIF.so /usr/share/orthanc/plugins-available/

COPY --from=build-downloader /downloads/libOsimisWebViewer.so /usr/share/orthanc/plugins-available/
COPY --from=build-downloader /downloads/libOsimisWebViewerAlpha.so /usr/share/orthanc/plugins-available/

COPY --from=build-s3-object-storage /build/libOrthancAwsS3Storage.so /usr/share/orthanc/plugins-available/

# If the target architecture is not AMD64, then delete the OsimisWebViewer &
# OsimisWebViewerAlpha plugin as they are only compatible with AMD64 builds
RUN if [[ ! -z "$TARGETPLATFORM" ]] && [[ "$TARGETPLATFORM" != "linux/amd64" ]]; then \
	rm /usr/share/orthanc/plugins-available/libOsimisWebViewer.so && \
	rm /usr/share/orthanc/plugins-available/libOsimisWebViewerAlpha.so; \
	fi

RUN chmod +x /usr/share/orthanc/plugins-available/*
RUN chmod +x /usr/local/bin/*

RUN pip install envsubst==0.1.5

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


# always create an 'orthanc' group (gid=999) and an orthanc user (uid=999)
# and grants him all permissions on files that can be modified by the docker-entrypoint.sh
# The default root users can still access these files too.
# for the /etc/hostid -> we must make sure the file exists to grant the permission
RUN groupadd --system orthanc --gid=999; \
    useradd --system --gid=orthanc --uid=999 --home-dir=/var/lib/orthanc --shell=/bin/false orthanc; \
    mkdir -p /var/lib/orthanc; \
    chown -R orthanc:orthanc /var/lib/orthanc; \
    chown -R orthanc:orthanc /tmp; \
    chown -R orthanc:orthanc /usr/share/orthanc/plugins; \
    chown -R orthanc:orthanc /usr/share/orthanc/plugins-available; \
    echo not-generated > /etc/hostid; \
    chown orthanc:orthanc /etc/hostid


################################# the "full" image that will run Orthanc dynamicaly linked (final version with vcpkg builds and Microsoft unixodbc)
FROM orthanc-no-vcpkg as orthanc-with-vcpkg

RUN apt-get update
RUN apt-get --assume-yes install curl gnupg2

RUN mkdir /downloads

RUN curl https://packages.microsoft.com/keys/microsoft.asc > /downloads/microsoft.asc
RUN curl https://packages.microsoft.com/config/debian/11/prod.list > /etc/apt/sources.list.d/mssql-release.list

RUN apt-key add /downloads/microsoft.asc
RUN apt-get update && \
    ACCEPT_EULA=Y apt-get install -y msodbcsql18 unixodbc-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY --from=build-google-object-storage /build/libOrthancGoogleCloudStorage.so /usr/share/orthanc/plugins-available/
COPY --from=build-azure-object-storage /build/libOrthancAzureBlobStorage.so /usr/share/orthanc/plugins-available/

RUN chmod +x /usr/share/orthanc/plugins-available/*
RUN chmod +x /usr/local/bin/*

