#!/usr/bin/env python3

# Orthanc - A Lightweight, RESTful DICOM Store
# Copyright (C) 2012-2016 Sebastien Jodogne, Medical Physics
# Department, University Hospital of Liege, Belgium
# Copyright (C) 2017-2024 Osimis S.A., Belgium
# Copyright (C) 2021-2024 Sebastien Jodogne, ICTEAM UCLouvain, Belgium
#
# This program is free software: you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public License
# as published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this program. If not, see
# <http://www.gnu.org/licenses/>.


import json
import os
import requests
import sys
import time
import zipfile

import Toolbox

if len(sys.argv) != 3:
    print('Usage: %s [target ZIP] [version]' % sys.argv[0])
    print('Example: %s /tmp/MacOS.zip 23.11.0' % sys.argv[0])
    exit(-1)

TARGET = sys.argv[1]
PREFIX = 'Orthanc-MacOS-%s' % sys.argv[2]


def AddContentToZip(archive, content, targetPath, isExecutable):
    info = zipfile.ZipInfo(os.path.join(PREFIX, targetPath))
    info.compress_type = zipfile.ZIP_DEFLATED  # If not set, no compression takes place
    info.date_time = time.localtime()

    if isExecutable:
        info.external_attr = 0o100755 << 16   # -rwxr-xr-x permissions (755 in octal)
    else:
        info.external_attr = 0o100644 << 16   # -rw-r--r-- permissions (644 in octal)

    archive.writestr(info, content)


def AddFile(archive, sourcePath, targetPath = None, isExecutable = False):
    if targetPath == None:
        targetPath = os.path.basename(sourcePath)

    with open(os.path.join(BASE, sourcePath), 'rb') as f:
        AddContentToZip(archive, f.read(), targetPath, isExecutable)


def DownloadFile(archive, url, targetPath = None, isExecutable = False):
    if targetPath == None:
        targetPath = url.split('/') [-1]

    print('    downloading: %s' % url)
    r = requests.get(url)
    r.raise_for_status()
    AddContentToZip(archive, r.content, targetPath, isExecutable)
    

BASE = os.path.join(os.path.dirname(os.path.realpath(__file__)), '..')


with open(os.path.join(BASE, 'build-matrix.json')) as f:
    matrix = json.loads(f.read())


with zipfile.ZipFile(TARGET, 'w', compression = zipfile.ZIP_DEFLATED) as archive:
    AddFile(archive, 'orthancBuildResources/readmeMacOS.txt', 'readme.txt')
    AddFile(archive, 'orthancBuildResources/configMacOS.json')
    AddFile(archive, 'orthancBuildResources/startOrthanc.command', isExecutable = True)
    AddFile(archive, 'WindowsInstaller/Resources/ca-certificates.crt')

    for project in matrix['configs']:
        if project['name'].startswith('XXXX'):   # This is a documentation
            continue

        if not 'downloadsMacOS' in project:
            print('Skipping project without MacOS binaries: %s' % project['name'])
            continue

        version = Toolbox.GetVersion(project)

        for f in project['downloadsMacOS']:
            if isinstance(f, str):
                url = f.replace('${VERSION}', version)
                DownloadFile(archive, url)
            else:
                url = f['url'].replace('${VERSION}', version)
                DownloadFile(archive, url, f.get('target', None), f.get('executable', False))
