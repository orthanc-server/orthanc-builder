#!/usr/bin/python3

import os
import argparse
import json
import shutil
import requests
import platform, sys, logging
from helpers import *

scriptDir = os.path.abspath(os.path.dirname(__file__))
sys.path.append(os.path.join(scriptDir, '/env/Scripts'))  # the aws cli is in env/Scripts

if platform.system() == 'Windows':
    awsExecutable = 'aws.cmd'
elif platform.system() == 'Darwin':
    awsExecutable = 'aws'


##
## Parse the command-line arguments
##

parser = argparse.ArgumentParser(description = 'Create the Osimis zip Package.')
parser.add_argument('stableOrNightly', choices = ['nightly', 'stable'])
parser.add_argument('--config',
                    default = None,
                    help = 'Config of the build')
parser.add_argument('--force', help = 'Reuse the working directory if it already exists',
                    action = 'store_true')
parser.add_argument('--clearBefore', help = 'Clear target directory before',
                    action = 'store_true', default = True)
parser.add_argument('--publishOnly', help = 'Skip download/zip phase and only try to upload to AWS',
                    action = 'store_true', default = False)
parser.add_argument('--target',
                    default = '/tmp/OsimisPackage',
                    help = 'Working directory')

args = parser.parse_args()

##
## Load and validate the configuration
##

if args.config == None:
    print('Please provide a configuration file')
    exit(-1)

with open(args.config, 'r') as f:
    CONFIG = json.loads(f.read())

ARCHITECTURE = CONFIG['Architecture']

if not ARCHITECTURE in [32, 64]:
    print('ERROR- The "Architecture" option must be set to 32 or 64')
    exit(-1)

##
## Prepare the working directory
##

SOURCE = os.path.normpath(os.path.dirname(__file__))
RESOURCES = os.path.normpath(os.path.join(os.path.dirname(__file__), "orthancBuildResources"))
TARGET = args.target

if not args.publishOnly:
    try:
        if args.clearBefore:
            shutil.rmtree(TARGET, ignore_errors = True)
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

if not args.publishOnly:
    if ARCHITECTURE in [32, 64]:
        shutil.copy(os.path.join(RESOURCES, "configWin.json"), TARGET)
        shutil.copy(os.path.join(RESOURCES, "startOrthanc.bat"), TARGET)
        shutil.copy(os.path.join(RESOURCES, "readmeWin.txt"), os.path.join(TARGET, "readme.txt"))
    else:
        shutil.copy(os.path.join(RESOURCES, "configOSX.json"), TARGET)
        shutil.copy(os.path.join(RESOURCES, "startOrthanc.command"), TARGET)
        shutil.copy(os.path.join(RESOURCES, "readmeOSX.txt"), os.path.join(TARGET, "readme.txt"))

##
## Download the build artifacts from the CIS
##

def Download(url, target):
    print('Downloading: %s' % url)
    f = requests.get(url)
    if f.status_code != 200:
        raise Exception('Cannot download: %s' % url)

    with open(target, 'wb') as g:
        g.write(f.content)


if not args.publishOnly:
    for component in CONFIG['Components']:
        artifactKey = 'Artifacts'
        if args.stableOrNightly == "nightly" and 'NightlyArtifacts' in component:
            artifactKey = 'NightlyArtifacts'
        if artifactKey in component:
            for artifact in component[artifactKey]:
                target = os.path.join(TARGET, os.path.basename(artifact[0]))
                CheckNotExisting(target)

                if not os.path.exists(target):
                    Download('%s/%s' % (CONFIG['CIS'], artifact[0]), target)


##
## Download additional resources
##

def GetDownloadBasename(f):
    return os.path.basename(f).split('?')[0]


if not args.publishOnly:
    for component in CONFIG['Components']:
        downloadKey = 'Downloads'
        if args.stableOrNightly == "nightly" and 'NightlyDownloads' in component:
            downloadKey = 'NightlyDownloads'
        if downloadKey in component:
            for download in component[downloadKey]:
                target = os.path.join(TARGET, GetDownloadBasename(download[0]))
                CheckNotExisting(target)

                if not os.path.exists(target):
                    Download(download[0], target)

##
## Generate the zips
##

if ARCHITECTURE == 32:
    zipFileName = 'orthancAndPluginsWin32.{}'.format(args.stableOrNightly)
    s3Path = '/win32/{}/'.format(args.stableOrNightly)
elif ARCHITECTURE == 64:
    zipFileName = 'orthancAndPluginsWin64.{}'.format(args.stableOrNightly)
    s3Path = '/win64/{}/'.format(args.stableOrNightly)
else:
    zipFileName = 'orthancAndPluginsOSX.{}'.format(args.stableOrNightly)
    s3Path = '/osx/{}/'.format(args.stableOrNightly)

if not args.publishOnly:
    # compress to zip and upload zip to s3
    shutil.make_archive(base_name = os.path.join(TARGET, "..", zipFileName),
                        format = 'zip',
                        root_dir = TARGET,
                        base_dir = None
                        )

LogHelpers.configureLogging(logging.INFO)
logger = LogHelpers.getLogger('LOG')

if platform.system() == "Windows":
    CmdHelpers.runExitIfFails('copying artifacts zip to s3',
                              'env\\Scripts\\activate.bat && {exe} s3 --region eu-west-1 cp {zipFile} s3://orthanc.osimis.io{path} --cache-control=max-age=1'.format(
                                  exe = awsExecutable,
                                  zipFile = os.path.join(TARGET, "..", zipFileName + ".zip"),
                                  path = s3Path),
                              scriptDir, logger.info)

# TODO: build a json doc with versions info that we can use in the orthanc.osimis.io index page

