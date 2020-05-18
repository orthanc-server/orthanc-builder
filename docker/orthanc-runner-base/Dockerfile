# base image to build and execute orthanc.  
# This image should contain only the packages that are common to both !
# The purpose of this intermediate image is to benefit from Docker cache.
FROM debian:buster-20200514-slim

RUN export DEBIAN_FRONTEND=noninteractive && \
  apt-get --assume-yes update && \
  apt-get --assume-yes install vim && \
  apt-get --assume-yes install wget && \
  apt-get --assume-yes install curl && \
  apt-get --assume-yes install python3.7 && \
  apt-get --assume-yes install python3-pip && \
  apt-get --assume-yes install ca-certificates && \
  apt-get --assume-yes install tzdata && \
  apt-get --assume-yes install locales && \
  apt-get --assume-yes install libdcmtk14 && \
  apt-get --assume-yes install libboost-log1.67.0 libboost-filesystem1.67.0 libboost-locale1.67.0 libboost-regex1.67.0 libboost-system1.67.0 libboost-thread1.67.0 && \
  apt-get --assume-yes install libjpeg62-turbo && \
  apt-get --assume-yes install libjsoncpp1 && \
  apt-get --assume-yes install liblua5.3 && \
  apt-get --assume-yes install libpng16-16 && \
  apt-get --assume-yes install libpugixml1v5 && \
  apt-get --assume-yes install libsqlite3-0 && \
  apt-get --assume-yes install libssl1.1 && \
  apt-get --assume-yes install libuuid1 && \
  apt-get --assume-yes install lsb-base && \
  apt-get --assume-yes install zlib1g && \
  apt-get --assume-yes install libpq5 && \
  apt-get --assume-yes install libmariadb3 && \
  apt-get --assume-yes clean && \
  rm --recursive --force /var/lib/apt/lists/*

# Make sure the en_US locale has been generated (required for
# case-insensitive comparison of strings with accents)
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
RUN locale-gen

#  apt-get --assume-yes install libjpeg-dev zlib1g-dev libdcmtk2-dev libboost-all-dev libwrap0-dev libcharls-dev libjsoncpp-dev libpugixml-dev && \
