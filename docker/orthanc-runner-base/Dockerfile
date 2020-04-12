# base image to build and execute orthanc.  
# This image should contain only the packages that are common to both !
# The purpose of this intermediate image is to benefit from Docker cache.
FROM ubuntu:19.10

RUN export DEBIAN_FRONTEND=noninteractive && \
	apt-get --assume-yes update && \
	apt-get --assume-yes install vim && \
	apt-get --assume-yes install wget && \
  apt-get --assume-yes install curl && \
  apt-get --assume-yes install python3.7 && \
	apt-get --assume-yes install ca-certificates && \
	apt-get --assume-yes install tzdata && \
	apt-get --assume-yes install locales && \
  apt-get --assume-yes install libjpeg-dev zlib1g-dev libdcmtk2-dev libboost-all-dev libwrap0-dev libcharls-dev libjsoncpp-dev libpugixml-dev && \
	apt-get --assume-yes clean && \
	rm --recursive --force /var/lib/apt/lists/* && \
	locale-gen en_US en_US.UTF-8
