FROM ubuntu:22.04

ENV DEBIAN_FRONTEND noninteractive

RUN dpkg --add-architecture i386
RUN apt-get update
RUN apt-get install -yq curl unrar unzip build-essential g++-mingw-w64 cmake python3 python3-pip vim mercurial wget software-properties-common apt-transport-https
RUN wget -nc https://dl.winehq.org/wine-builds/winehq.key
RUN apt-key add winehq.key
RUN apt-add-repository https://dl.winehq.org/wine-builds/ubuntu/
RUN apt-get update
# RUN sed -i "s/main/main contrib non-free/" etc/apt/sources.list
RUN apt-get install -yq wine 

# innosetup
RUN mkdir innosetup && \
    cd innosetup && \
    curl -fsSL -o innounp045.rar "https://downloads.sourceforge.net/project/innounp/innounp/innounp%200.45/innounp045.rar?r=&ts=1439566551&use_mirror=skylineservers" && \
    unrar e innounp045.rar

RUN cd innosetup && \
    curl -fsSL -o is-unicode.exe http://files.jrsoftware.org/is/5/isetup-5.5.8-unicode.exe && \
    wine "./innounp.exe" -e "is-unicode.exe"

RUN pip3 install requests

COPY build-matrix.json /
COPY WindowsInstaller/ /tmp/WindowsInstaller
COPY UCLouvain/ /tmp/UCLouvain

WORKDIR /tmp/WindowsInstaller

ARG PLATFORM
ARG VERSION

RUN python3 --version
RUN python3 -u ./CreateInstaller.py --matrix=/build-matrix.json --platform=${PLATFORM} --version=${VERSION}  --from-docker
