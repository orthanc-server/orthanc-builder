#!/usr/bin/env bash
set -o errexit

cd azure-storage-cpp/Microsoft.WindowsAzure.Storage/
mkdir build.release
cd build.release
CASABLANCA_DIR=/root/casablanca cmake ..
make
make install
