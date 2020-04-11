# base image to build and execute orthanc.  
# This image should contai only the packages that are common to both !
# The purpose of this intermediate image is to benefit from Docker cache.
FROM ubuntu:19.10 as base

RUN export DEBIAN_FRONTEND=noninteractive && \
	apt-get --assume-yes update && \
	apt-get --assume-yes install vim && \
	apt-get --assume-yes install wget && \
  apt-get --assume-yes install curl && \
	apt-get --assume-yes install ca-certificates && \
	apt-get --assume-yes install tzdata && \
	apt-get --assume-yes install locales && \
  apt-get --assume-yes install libjpeg-dev zlib1g-dev libdcmtk2-dev libboost-all-dev libwrap0-dev libcharls-dev libjsoncpp-dev libpugixml-dev && \

	apt-get --assume-yes clean && \
	rm --recursive --force /var/lib/apt/lists/* && \
	locale-gen en_US en_US.UTF-8


# image to compile Orthanc and its plugins dynamically
FROM ubuntu:19.10 as orthanc-base-dyn-builder

RUN apt-get --assume-yes update
RUN apt-get --assume-yes install git 
RUN apt-get --assume-yes install mercurial 
RUN apt-get --assume-yes install vim
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
RUN export DEBIAN_FRONTEND=noninteractive && \
  apt-get --assume-yes install locales ca-certificates tzdata && \
 	locale-gen en_US en_US.UTF-8
# RUN apt-get --assume-yes install libcivetweb-devel

RUN mkdir -p /sources
RUN mkdir -p /build

# RUN export DEBIAN_FRONTEND=noninteractive && \
# 	apt-get --assume-yes update && \
# 	apt-get --assume-yes install locales ca-certificates wget tzdata && \
# 	apt-get --assume-yes clean && \
# 	rm --recursive --force /var/lib/apt/lists/* && \
# 	locale-gen en_US en_US.UTF-8

FROM orthanc-base-dyn-builder as build-orthanc

RUN hg clone https://hg.orthanc-server.com/orthanc/ -r "Orthanc-1.6.0" /sources
# WORKDIR /sources/orthanc
# RUN hg up -c "Orthanc-1.6.0"
WORKDIR /build
RUN cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DSTANDALONE_BUILD=ON -DUSE_GOOGLE_TEST_DEBIAN_PACKAGE=ON -DUSE_SYSTEM_CIVETWEB=OFF /sources
RUN make -j 4

################################# the image that will run Orthanc dynamicaly linked
FROM ubuntu:19.10
RUN apt-get --assume-yes update
RUN apt-get --assume-yes install vim
RUN apt-get --assume-yes install wget
RUN apt-get --assume-yes install apt-transport-https
RUN apt-get --assume-yes install uuid
RUN apt-get --assume-yes install libjpeg-dev zlib1g-dev libdcmtk2-dev libboost-all-dev libwrap0-dev libcharls-dev libjsoncpp-dev libpugixml-dev
RUN export DEBIAN_FRONTEND=noninteractive && \
  apt-get --assume-yes install locales ca-certificates tzdata && \
 	locale-gen en_US en_US.UTF-8
RUN apt-get --assume-yes install curl
RUN apt-get --assume-yes install liblua5.1-0


COPY --from=build-orthanc /build/Orthanc /usr/bin/Orthanc
RUN ldd /usr/bin/Orthanc

RUN mkdir -p /etc/orthanc
SHELL ["/bin/bash", "-c"]
ENTRYPOINT ["/usr/bin/Orthanc"]
CMD ["/etc/orthanc"]
