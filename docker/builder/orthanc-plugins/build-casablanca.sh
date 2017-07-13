#!/usr/bin/env bash
set -o errexit

git clone "--branch=v$1" \
	--single-branch \
	https://github.com/Microsoft/cpprestsdk.git \
	casablanca
cd casablanca/Release
mkdir build.release
cd build.release
cmake ..
make
make install
