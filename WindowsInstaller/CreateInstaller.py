#!/usr/bin/python

# Orthanc - A Lightweight, RESTful DICOM Store
# Copyright (C) 2012-2016 Sebastien Jodogne, Medical Physics
# Department, University Hospital of Liege, Belgium
# Copyright (C) 2017-2023 Osimis S.A., Belgium
# Copyright (C) 2021-2023 Sebastien Jodogne, ICTEAM UCLouvain, Belgium
#
# This program is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

# example usage
# python3 ./CreateInstaller.py --matrix=../build-matrix.json  --platform=64 --version=22.4.0 --force

import os
import subprocess
import argparse
import json
import shutil
import requests


##
## Parse the command-line arguments
##

parser = argparse.ArgumentParser(description = 'Create the Osimis installer.')
parser.add_argument('--matrix', 
                    default = None,
                    help = 'Build matrix of the build')
parser.add_argument('--platform', 
                    default = "64",
                    type=str,
                    help = '32/64')
parser.add_argument('--version', 
                    default = None,
                    help = 'the version of the installer (ex: 22.4.0)')
parser.add_argument('--target', 
                    default = '/tmp/OsimisInstaller',
                    help = 'Working directory')
parser.add_argument('--force', help = 'Reuse the working directory if it already exists',
                    action = 'store_true')
parser.add_argument('--from-docker', help = 'In Docker, ISCC.exe is in /innosetup insteald of C:\Program Files (x86)',
                    action = 'store_true')

args = parser.parse_args()


##
## Load and validate the configuration
##

if args.matrix == None:
    print('Please provide a build matrix configuration file')
    exit(-1)

with open(args.matrix, 'r') as f:
    MATRIX = json.loads(f.read())

ARCHITECTURE = args.platform
VERSION = args.version

if not ARCHITECTURE in [ "32", "64" ]:
    print('ERROR- The "Architecture" option must be set to 32 or 64')
    exit(-1)

ARTIFACTS_KEY = f"Artifacts{ARCHITECTURE}"
DOWNLOADS_KEY = f"Downloads{ARCHITECTURE}"
CIS = "https://alain:koo4oCah@buildbot.orthanc-server.com/artifacts/Binaries"

##
## Prepare the working directory
##

SOURCE = os.path.normpath(os.path.dirname(__file__))
TARGET = args.target

try:
    os.makedirs(TARGET)
except:
    if args.force:
        print('Reusing the target directory "%s"' % TARGET)
    else:
        print('ERROR- Please remove directory "%s" or add the "--force" flag' % TARGET)
        exit(-1)

def SafeMakedirs(path):
    try:
        os.makedirs(os.path.join(TARGET, path))
    except:
        pass

def CheckNotExisting(path):
    if os.path.exists(path) and not args.force:
        print('ERROR- Two distinct files with the same name exist: %s' % path)
        exit(-1)

SafeMakedirs('Artifacts')
SafeMakedirs('Configuration')
SafeMakedirs('Downloads')
SafeMakedirs('Resources')

for resource in os.listdir(os.path.join(SOURCE, 'Resources')):
    source = os.path.join(SOURCE, 'Resources', resource)
    target = os.path.join(TARGET, 'Resources', resource)

    if os.path.isfile(source):
        CheckNotExisting(target)
        shutil.copy(source, target);


def Download(url, target):
    print (f"Downloading: {url} to {target}")
    r = requests.get(url)
    if r.status_code != 200:
        raise Exception('Cannot download: %s' % url)
    
    with open(target, 'wb') as g:
        g.write(r.content)

def GetDownloadBasename(download):
    if len(download) <= 2:
        return os.path.basename(download[0]).split('?')[0]
    else:
        return download[2]

def GetArtifactBasename(artifact):
    # 2 of artifact can be a comment or a rename
    if len(artifact) >=3 and ".dll" in artifact[2] or ".exe" in artifact[2]:
        # rename the artifact
        return artifact[2]
    else:
        return os.path.basename(artifact[0])


CATEGORIES = {
    'none': None,
    'plugins' : 'Official plugins',
    'osimis' : 'Plugins by Osimis',
    'python_plugins' : 'Python plugins (requires Python installed on your system)',
    'tools' : 'Command-line tools',
    'tools/wsi' : 'WSI Command-line tools'
    }

COMPONENTS_BY_CATEGORIES = {}
COMPONENTS = []
FILES = []
# HAS_CATEGORIES = []

count = 0

for repo in MATRIX['configs']:
    if 'windows' in repo and len(repo['windows']) > 0:

        for component in repo['windows']:

            if component.get('Exclude') == True or len(component) == 0:
                continue

            # downloads

            if ARTIFACTS_KEY in component:
                for artifact in component[ARTIFACTS_KEY]:
                    target = os.path.join(TARGET, 'Artifacts', GetArtifactBasename(artifact))
                    CheckNotExisting(target)

                    if not os.path.exists(target):
                        Download(f"{CIS}/{artifact[0]}", target)

            if DOWNLOADS_KEY in component:
                for download in component[DOWNLOADS_KEY]:
                    target = os.path.join(TARGET, 'Downloads', GetDownloadBasename(download))
                    CheckNotExisting(target)

                    if not os.path.exists(target):
                        Download(download[0], target)

            # generate list of components and files

            if 'Name' in component:
                name = component['Name']
            else:
                name = 'component%02d' % count
                count += 1

            if 'Category' in component:
                category = component['Category']
                name = '%s\\%s' % (category, name)
            else:
                category = 'none'

            if not category in COMPONENTS_BY_CATEGORIES:
                COMPONENTS_BY_CATEGORIES[category] = []

            flags = []
            if component['Mandatory']:
                options = 'Types: standard compact custom'
                flags.append('fixed')
            elif 'Checked' in component and not component['Checked']: 
                options = 'Types: '
            else:
                options = 'Types: standard'

            if 'Exclusive' in component and component['Exclusive']:
                flags.append("exclusive")
            if len(flags) > 0:
                if len(options) > 0:
                    options += '; '
                options += "Flags: " + " ".join(flags)


            COMPONENTS_BY_CATEGORIES[category].append('Name: "%s"; Description: "%s"; %s' % (
                                                      name, component['Description'], options))

            if ARTIFACTS_KEY in component:
                for artifact in component[ARTIFACTS_KEY]:
                    FILES.append('Source: "Artifacts/%s"; DestDir: "{app}/%s"; Components: %s' % (
                                GetArtifactBasename(artifact), artifact[1], name))

            if DOWNLOADS_KEY in component:
                for download in component[DOWNLOADS_KEY]:
                    FILES.append('Source: "Downloads/%s"; DestDir: "{app}/%s"; Components: %s' % (
                                GetDownloadBasename(download), download[1], name))

            if 'Resources' in component:
                for resource in component['Resources']:
                    s = 'Source: "Resources/%s"; DestDir: "{app}/%s"; Components: %s' % (
                        resource[0], resource[1], name)

                    if resource[1] == 'Configuration':
                        s += '; Flags: onlyifdoesntexist uninsneveruninstall'
                    
                    FILES.append(s)

for category in CATEGORIES:
    if category in COMPONENTS_BY_CATEGORIES:
        if category != 'none':
            if category == 'python_plugins':
                COMPONENTS.append('Name: "%s"; Description: "%s"; Types: ' % (category, CATEGORIES[category]))
            else:
                COMPONENTS.append('Name: "%s"; Description: "%s"; Types: standard' % (category, CATEGORIES[category]))

        for c in COMPONENTS_BY_CATEGORIES[category]:
            COMPONENTS.append(c)


##
## Generate the default configuration file
##

if True:
    # 2018-04-18: This command works on SJ's computer, even on 64bit
    # archictures. Install package "winehq-stable" from:
    # https://wiki.winehq.org/Ubuntu
    subprocess.check_call([ 'wine', 'Artifacts/Orthanc.exe',
                            '--config=orthanc.json' ],
                          cwd = TARGET)

else:
    if CONFIG['Architecture'] == 32:
        # this works only with a 32bits wine
        subprocess.check_call([ 'wine', 'Artifacts/Orthanc.exe',
                                '--config=orthanc.json' ],
                              cwd = TARGET)
    else:
        # it will be copied by the ci script (we'll use the one generated by the 32 bits installer)
        CheckNotExisting(os.path.join(TARGET, 'orthanc.json'))
        shutil.copy('orthanc.json', os.path.join(TARGET, 'orthanc.json'));
                                             



##
## Generate the list of components and files
## 


##
## Compile the Windows service and the configuration generator (always
## as a 32-bit program)
##

subprocess.check_call([ 'cmake', 
                        os.path.abspath(os.path.join(SOURCE, 'Configuration')), 
                        '-DCMAKE_BUILD_TYPE=Release',
                        ],
                      cwd = os.path.join(TARGET, 'Configuration'))

subprocess.check_call([ 'make', '-j4' ],
                      cwd = os.path.join(TARGET, 'Configuration'))


##
## Create the InnoSetup configuration
##

# MERCURIAL_REVISION = subprocess.check_output([ 'hg', 'identify', '--num', '-r', '.' ],
#                                              cwd = SOURCE)

SETUP_64 = '''
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64
'''

with open(os.path.join(SOURCE, 'Installer.innosetup'), 'r') as f:
    installer = f.read()

installer = installer.replace('${ORTHANC_NAME}', f"Orthanc for Windows {ARCHITECTURE}")
installer = installer.replace('${ORTHANC_VERSION}', VERSION)
installer = installer.replace('${ORTHANC_COMPONENTS}', '\n'.join(COMPONENTS))
installer = installer.replace('${ORTHANC_FILES}', '\n'.join(FILES))
# installer = installer.replace('${MERCURIAL_REVISION}', MERCURIAL_REVISION)
installer = installer.replace('${ORTHANC_ARCHITECTURE}', str(ARCHITECTURE))
installer = installer.replace('${ORTHANC_SETUP}', 
                              SETUP_64 if ARCHITECTURE == "64" else '')

with open(os.path.join(TARGET, 'Installer.innosetup'), 'w') as g:
    g.write(installer)

shutil.copyfile(os.path.join(SOURCE, 'ServiceControl.iss'),
                os.path.join(TARGET, 'ServiceControl.iss'))

shutil.copyfile(os.path.join(SOURCE, 'AppProcessMessages.iss'),
                os.path.join(TARGET, 'AppProcessMessages.iss'))



##
## Run InnoSetup
##

# WARNING: Inno Setup 6 is *not* compatible with Windows XP and
# shouldn't be used

innoSetupPath = 'c:/Program Files (x86)/Inno Setup 5/ISCC.exe'
if args.from_docker:
    innoSetupPath = '/innosetup/ISCC.exe'


subprocess.check_call([ 'wine',
                        innoSetupPath,
                        'Installer.innosetup' ],
                      cwd = TARGET)

print('\n\nThe installer is inside the following location:\n%s\n\n' % TARGET)
