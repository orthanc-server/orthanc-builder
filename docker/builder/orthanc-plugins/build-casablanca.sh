#!/usr/bin/env bash
set -o errexit

cd casablanca/Release
mkdir build.release
cd build.release
cmake ..
make
make install
