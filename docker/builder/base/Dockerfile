FROM ubuntu:16.04
LABEL Description="Base environment to build Orthanc"

# We keep hitting the 91.189.88.162 mirror from Belgian networks and it
# seems it (and maybe others) contain corrupt packages (e.g. logrotate,
# libuuid).
#
# https://paste.ubuntu.com/25579603/
# https://paste.ubuntu.com/25579606/
# RUN sed 's@archive.ubuntu.com@mir1.ovh.net@' -i /etc/apt/sources.list

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install wget nano build-essential unzip cmake mercurial uuid-dev libcurl4-openssl-dev liblua5.1-0-dev libgtest-dev libpng-dev libsqlite3-dev libssl-dev libjpeg-dev zlib1g-dev libdcmtk2-dev libboost-all-dev libwrap0-dev libcharls-dev locales libjsoncpp-dev libpugixml-dev && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US
RUN locale-gen en_US.UTF-8
RUN update-locale 
