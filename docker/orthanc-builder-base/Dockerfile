# image to compile Orthanc and its plugins dynamically
FROM osimis/orthanc-runner-base:current

RUN apt-get --assume-yes update
RUN apt-get --assume-yes install wget
RUN apt-get --assume-yes install build-essential
RUN apt-get --assume-yes install unzip
RUN apt-get --assume-yes install cmake
RUN apt-get --assume-yes install uuid-dev
RUN apt-get --assume-yes install apt-utils
RUN apt-get --assume-yes install libcurl4-openssl-dev
RUN apt-get --assume-yes install curl
RUN apt-get --assume-yes install apt-transport-https
RUN apt-get --assume-yes install liblua5.1-0-dev
RUN apt-get --assume-yes install libgtest-dev
RUN apt-get --assume-yes install libpng-dev
RUN apt-get --assume-yes install libsqlite3-dev
RUN apt-get --assume-yes install libjpeg-dev zlib1g-dev libdcmtk2-dev libboost-all-dev libwrap0-dev libcharls-dev libjsoncpp-dev libpugixml-dev
RUN apt-get --assume-yes install git
RUN apt-get --assume-yes install mercurial
# RUN apt-get --assume-yes install libcivetweb-devel

# TODO: cleanup apt cache ...

RUN mkdir -p /sources
RUN mkdir -p /build
