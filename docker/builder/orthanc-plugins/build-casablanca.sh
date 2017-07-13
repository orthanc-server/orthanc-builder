#!/usr/bin/env bash
set -o errexit

git clone https://github.com/Microsoft/cpprestsdk.git casablanca
cd casablanca/Release
mkdir build.release
cd build.release
cmake ..
make
make install
