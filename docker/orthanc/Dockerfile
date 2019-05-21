FROM ubuntu:16.04
SHELL ["/bin/bash", "-c"]
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/etc/orthanc"]

# enable lua to find external modules (this list is obtained by running "return package.path" in a lua prompt)
ENV LUA_PATH="./?.lua;/usr/local/share/lua/5.1/?.lua;/usr/local/share/lua/5.1/?/init.lua;/usr/local/lib/lua/5.1/?.lua;/usr/local/lib/lua/5.1/?/init.lua;/usr/share/lua/5.1/?.lua;/usr/share/lua/5.1/?/init.lua"
ENV LUA_CPATH="./?.so;/usr/local/lib/lua/5.1/?.so;/usr/lib/x86_64-linux-gnu/lua/5.1/?.so;/usr/lib/lua/5.1/?.so;/usr/local/lib/lua/5.1/loadall.so"

RUN export DEBIAN_FRONTEND=noninteractive && \
	apt-get --assume-yes update && \
	apt-get --assume-yes install locales ca-certificates wget && \
	apt-get --assume-yes clean && \
	rm --recursive --force /var/lib/apt/lists/* && \
	locale-gen en_US en_US.UTF-8

RUN mkdir --parents \
	/etc/orthanc \
	/usr/lib/orthanc/setup.d \
	/usr/share/orthanc/plugins \
  /usr/share/orthanc/plugins-disabled

# CHANGE_VERSION_WVB
RUN wget http://orthanc.osimis.io/lsb/plugin-osimis-webviewer/releases/1.2.0/libOsimisWebViewer.so --output-document /usr/share/orthanc/plugins-disabled/libOsimisWebViewer.so --quiet

# CHANGE_VERSION_WVB_ALPHA
RUN wget http://orthanc.osimis.io/lsb/plugin-osimis-webviewer/commits/7c4d1a44/libOsimisWebViewer.so --output-document /usr/share/orthanc/plugins-disabled/libOsimisWebViewerAlpha.so --quiet

# CHANGE_VERSION_ORTHANC
RUN wget http://orthanc.osimis.io/lsb/orthanc/changesets/974e12006b7d/Orthanc --output-document /usr/bin/Orthanc --quiet
RUN wget http://orthanc.osimis.io/lsb/orthanc/releases/1.5.6/OrthancRecoverCompressedFile --output-document /usr/bin/OrthancRecoverCompressedFile --quiet
RUN wget http://orthanc.osimis.io/lsb/orthanc/releases/1.5.6/libModalityWorklists.so --output-document /usr/share/orthanc/plugins-disabled/libModalityWorklists.so --quiet
RUN wget http://orthanc.osimis.io/lsb/orthanc/releases/1.5.6/libServeFolders.so --output-document /usr/share/orthanc/plugins-disabled/libServeFolders.so --quiet

# CHANGE_VERSION_DW
RUN wget http://orthanc.osimis.io/lsb/plugin-dicomweb/releases/0.6/libOrthancDicomWeb.so --output-document /usr/share/orthanc/plugins-disabled/libOrthancDicomWeb.so --quiet

# CHANGE_VERSION_PG
RUN wget http://orthanc.osimis.io/lsb/plugin-postgresql/releases/3.2/libOrthancPostgreSQLIndex.so --output-document /usr/share/orthanc/plugins-disabled/libOrthancPostgreSQLIndex.so --quiet
RUN wget http://orthanc.osimis.io/lsb/plugin-postgresql/releases/3.2/libOrthancPostgreSQLStorage.so --output-document /usr/share/orthanc/plugins-disabled/libOrthancPostgreSQLStorage.so --quiet

# CHANGE_VERSION_MY_SQL
RUN wget http://orthanc.osimis.io/lsb/plugin-mysql/releases/2.0/libOrthancMySQLIndex.so --output-document /usr/share/orthanc/plugins-disabled/libOrthancMySQLIndex.so --quiet
RUN wget http://orthanc.osimis.io/lsb/plugin-mysql/releases/2.0/libOrthancMySQLStorage.so --output-document /usr/share/orthanc/plugins-disabled/libOrthancMySQLStorage.so --quiet

# CHANGE_VERSION_ORTHANC_WEB_VIEWER
RUN wget http://orthanc.osimis.io/lsb/plugin-webviewer/releases/2.5/libOrthancWebViewer.so --output-document /usr/share/orthanc/plugins-disabled/libOrthancWebViewer.so --quiet

# CHANGE_VERSION_ORTHANC_WSI
RUN wget http://orthanc.osimis.io/lsb/whole-slide-imaging/releases/0.6/libOrthancWSI.so --output-document /usr/share/orthanc/plugins-disabled/libOrthancWSI.so --quiet
RUN wget http://orthanc.osimis.io/lsb/whole-slide-imaging/releases/0.6/OrthancWSIDicomToTiff --output-document /usr/bin/OrthancWSIDicomToTiff --quiet
RUN wget http://orthanc.osimis.io/lsb/whole-slide-imaging/releases/0.6/OrthancWSIDicomizer --output-document /usr/bin/OrthancWSIDicomizer --quiet

# CHANGE_VERSION_AUTH   # note: lsb build does not work for 0.2.2 !
RUN wget http://orthanc.osimis.io/docker-so/orthanc-authorization/0.2.2/libOrthancAuthorization.so --output-document /usr/share/orthanc/plugins-disabled/libOrthancAuthorization.so --quiet

# CHANGE_VERSION_TRANSFERS
RUN wget http://orthanc.osimis.io/lsb/plugin-transfers/releases/1.0/libOrthancTransfers.so --output-document /usr/share/orthanc/plugins-disabled/libOrthancTransfers.so --quiet

# make all downloaded binaries executable
RUN chmod +x /usr/bin/*
RUN chmod +x /usr/share/orthanc/plugins-disabled/*

COPY orthanc/docker-entrypoint.sh /
COPY orthanc/setup.sh /usr/lib/orthanc/
COPY orthanc/setup.d/* /usr/lib/orthanc/setup.d/
