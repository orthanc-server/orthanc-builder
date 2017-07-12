#!/usr/bin/env bash

# Orthanc - A Lightweight, RESTful DICOM Store
# Copyright (C) 2012-2015 Sebastien Jodogne, Medical Physics
# Department, University Hospital of Liege, Belgium
#
# This program is free software: you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License
# as published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Affero General Public License for more details.
# 
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

set -o errexit

# Get the number of available cores to speed up the builds
COUNT_CORES=$(grep --count ^processor /proc/cpuinfo)
echo "Will use $COUNT_CORES parallel jobs to build Orthanc"

# Clone the repository and switch to the requested branch
hg clone https://bitbucket.org/sjodogne/orthanc-postgresql/
cd orthanc-postgresql
hg up -c "$1"

# Build the plugin
mkdir Build
cd Build
cmake -DALLOW_DOWNLOADS=ON \
	-DSTATIC_BUILD=ON \
	-DCMAKE_BUILD_TYPE=Release \
	..
make "--jobs=$COUNT_CORES"
cp --dereference libOrthancPostgreSQLIndex.so /usr/share/orthanc/plugins/
cp --dereference libOrthancPostgreSQLStorage.so /usr/share/orthanc/plugins/

# Remove the build directory to recover space
cd /root/
rm -rf /root/orthanc-postgresql
