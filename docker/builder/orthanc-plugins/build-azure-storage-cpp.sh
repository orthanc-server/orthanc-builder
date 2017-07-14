#!/usr/bin/env bash
set -o errexit

git clone "--branch=v$1" \
	--single-branch \
	https://github.com/Azure/azure-storage-cpp.git
cd azure-storage-cpp/Microsoft.WindowsAzure.Storage/
mkdir build.release
cd build.release
CASABLANCA_DIR=/root/casablanca cmake ..
make
make install
