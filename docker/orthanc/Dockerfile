FROM ubuntu:16.04
SHELL ["/bin/bash", "-c"]
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/etc/orthanc"]

# enable lua to find external modules (this list is obtained by running "return package.path" in a lua prompt)
ENV LUA_PATH="./?.lua;/usr/local/share/lua/5.1/?.lua;/usr/local/share/lua/5.1/?/init.lua;/usr/local/lib/lua/5.1/?.lua;/usr/local/lib/lua/5.1/?/init.lua;/usr/share/lua/5.1/?.lua;/usr/share/lua/5.1/?/init.lua"
ENV LUA_CPATH="./?.so;/usr/local/lib/lua/5.1/?.so;/usr/lib/x86_64-linux-gnu/lua/5.1/?.so;/usr/lib/lua/5.1/?.so;/usr/local/lib/lua/5.1/loadall.so"

RUN export DEBIAN_FRONTEND=noninteractive && \
	apt-get --assume-yes update && \
	apt-get --assume-yes install locales ca-certificates && \
	apt-get --assume-yes clean && \
	rm --recursive --force /var/lib/apt/lists/* && \
	locale-gen en_US en_US.UTF-8

RUN mkdir --parents \
	/etc/orthanc \
	/usr/lib/orthanc/setup.d \
	/usr/share/orthanc/plugins

COPY orthanc/docker-entrypoint.sh /
COPY orthanc/setup.sh /usr/lib/orthanc/
COPY orthanc/setup.d/* /usr/lib/orthanc/setup.d/
COPY binaries/plugins/ /usr/share/orthanc/plugins-disabled
COPY binaries/executables/ /usr/bin
