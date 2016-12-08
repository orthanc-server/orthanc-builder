import logging
import argparse
import platform
import os
import shutil
import sys
from helpers import *

LogHelpers.configureLogging(logging.INFO)
logger = LogHelpers.getLogger('LOG')

scriptDir = os.path.abspath(os.path.dirname(__file__))
sys.path.append(os.path.join(scriptDir, '/env/Scripts'))  # the aws cli is in env/Scripts

if platform.system() == 'Windows':
    awsExecutable = 'aws.cmd'
elif platform.system() == 'Darwin':
    awsExecutable = 'aws'

WINDOWS = 'Windows'
OSX = 'Darwin'
LINUX = 'Linux'
ALL_PLATFORMS = [WINDOWS, OSX, LINUX]

repositories = {
    'orthanc': {
        'url': 'https://bitbucket.org/sjodogne/orthanc',
        'localName': 'orthanc.hg',
        'tool': 'hg',
        'platforms': ALL_PLATFORMS,
        'build': {
            'type': 'cmake',
            'cmakeTarget': 'Orthanc',
            'cmakeTargetsOSX': ['Orthanc', 'ServeFolders', 'ModalityWorklists', 'UnitTests'],
            # in osx: the names of the 2 targets in the xcodeproj
            'cmakeOptions': ['-DSTANDALONE_BUILD=ON', '-DSTATIC_BUILD=ON', '-DALLOW_DOWNLOADS=ON',
                             '-DUNIT_TESTS_WITH_HTTP_CONNEXIONS=OFF'],
            # www.montefiore.ulg.ac.be not always accessible from the labs => remove these tests
            'buildFromFolder': '.',
            'buildOutputFolder': '../orthanc.hg-build',
            'unitTestsExe': 'UnitTests'
        },
        'stableBranch': 'Orthanc-1.1.0',
        'nightlyBranch': 'default',
        'outputLibs': ['ServeFolders', 'ModalityWorklists'],
        'outputExes': ['Orthanc'],
    },
    'viewer': {
        'platforms': ALL_PLATFORMS,
        'stableBranch': 'master',
        'nightlyBranch': 'dev',
        'outputLibs': ['OsimisWebViewer'],
    },
    'dicomweb': {
        'url': 'https://bitbucket.org/sjodogne/orthanc-dicomweb',
        'localName': 'orthanc-dicomweb.hg',
        'tool': 'hg',
        'platforms': ALL_PLATFORMS,
        'build': {
            'type': 'cmake',
            'cmakeTarget': 'OrthancDicomWeb',
            'cmakeTargetsOSX': ['OrthancDicomWeb', 'UnitTests'],
            'cmakeOptions': ['-DSTANDALONE_BUILD=ON', '-DSTATIC_BUILD=ON', '-DALLOW_DOWNLOADS=ON'],
            'buildFromFolder': '.',
            'buildOutputFolder': '../orthanc-dicomweb.hg-build',
            'unitTestsExe': 'UnitTests'
        },
        'stableBranch': '1adc7c4',  # OrthancDicomWeb-0.3.0'
        'nightlyBranch': 'default',
        'outputLibs': ['OrthancDicomWeb'],
    },
    'wsiplugin': {
        'url': 'https://bitbucket.org/sjodogne/orthanc-wsi',
        'localName': 'orthanc-wsi-plugin.hg',
        'tool': 'hg',
        'platforms': [WINDOWS],
        'build': {
            'type': 'cmake',
            'cmakeTarget': 'OrthancWSIPlugin',
            'cmakeTargetsOSX': ['OrthancWSIPlugin'],
            'cmakeOptions': ['-DSTANDALONE_BUILD=ON', '-DSTATIC_BUILD=ON', '-DALLOW_DOWNLOADS=ON'],
            'buildFromFolder': 'ViewerPlugin',
            'buildOutputFolder': '../orthanc-wsi-plugin.hg-build'
        },
        'stableBranch': 'OrthancWSI-0.1', 
        'nightlyBranch': 'default',
        'outputLibs': ['OrthancWSI'],
    },
    'wsiapps': {
        'url': 'https://bitbucket.org/sjodogne/orthanc-wsi',
        'localName': 'orthanc-wsi-apps.hg',
        'tool': 'hg',
        'platforms': [WINDOWS],
        'build': {
            'type': 'cmake',
            'cmakeTarget': 'OrthancWSIApplications',
            'cmakeTargetsOSX': ['OrthancWSIApplications'],
            'cmakeOptions': ['-DSTANDALONE_BUILD=ON', '-DSTATIC_BUILD=ON', '-DALLOW_DOWNLOADS=ON'],
            'buildFromFolder': 'Applications',
            'buildOutputFolder': '../orthanc-wsi-apps.hg-build'
        },
        'stableBranch': 'OrthancWSI-0.1', 
        'nightlyBranch': 'default',
        'outputExes': ['OrthancWSIDicomizer', 'OrthancWSIDicomToTiff'],
    },
    'postgresql': {
        'url': 'https://bitbucket.org/sjodogne/orthanc-postgresql/',
        'localName': 'orthanc-postgresql.hg',
        'tool': 'hg',
        'platforms': ALL_PLATFORMS, # it currently does not build with VS2015
        'build': {
            'type': 'cmake',
            'cmakeTarget': 'OrthancPostgreSQL',
            'cmakeTargetsOSX': ['OrthancPostgreSQLStorage', 'OrthancPostgreSQLIndex'], # 'UnitTests'],
            # in windows: the name of the .sln file with 2 projects: Storage and Index
            'cmakeOptions': ['-DSTANDALONE_BUILD=ON', '-DSTATIC_BUILD=ON', '-DALLOW_DOWNLOADS=ON'],
            'buildFromFolder': '.',
            'buildOutputFolder': '../orthanc-postgresql.hg-build',
            # don't run unit tests since it requires a postgresql server deployed   unitTestsExe': 'UnitTests' 
        },
        'stableBranch': '1e2c87b', # OrthancPostgreSQL-2.0',
        'nightlyBranch': 'default',
        'outputLibs': ['OrthancPostgreSQLStorage', 'OrthancPostgreSQLIndex'], # todo, we actualy never built the postgresql with this script ...
    }
}


def getBuilder(archi, vsVersion):
    if platform.system() == 'Windows':
        if archi == 'win32' and vsVersion == '2013':
            builder = BuildHelpers.BUILDER_VS2013_32BITS
        elif archi == 'win32' and vsVersion == '2015':
            builder = BuildHelpers.BUILDER_VS2015_32BITS
        elif archi == 'win64' and vsVersion == '2013':
            builder = BuildHelpers.BUILDER_VS2013_64BITS
        elif archi == 'win64' and vsVersion == '2015':
            builder = BuildHelpers.BUILDER_VS2015_64BITS
    elif platform.system() == 'Darwin':
        builder = BuildHelpers.BUILDER_XCODE
    return builder


def getAwsConfigFolder(archi):
    if platform.system() == 'Windows':
        if archi == 'win32':
            return 'win32'
        else:
            return 'win64'
    elif platform.system() == 'Darwin':
        return 'osx'


def packageOrthancAndPlugins(stableOrNightly, archi):
    if platform.system() == 'Windows':
        if archi == 'win32':
            zipFileName = 'orthancAndPluginsWin32.{}'.format(stableOrNightly)
        else:
            zipFileName = 'orthancAndPluginsWin64.{}'.format(stableOrNightly)
        s3Path = '/{}/{}/'.format(archi, stableOrNightly)
    else:
        zipFileName = 'orthancAndPluginsOSX.{}'.format(stableOrNightly)
        s3Path = '/osx/{}/'.format(stableOrNightly)

    # copy artifacts in a dedicated folder
    artifactsPath = os.path.join(scriptDir, zipFileName)
    FileHelpers.makeSurePathDoesNotExists(artifactsPath)  # first empty the zip folder
    FileHelpers.makeSurePathExists(artifactsPath)  # and create the folder to zip

    for projectName in repositories.keys():
        repository = repositories[projectName]
        if stableOrNightly == 'stable':
            branchName = repository['stableBranch']
        else:
            branchName = repository['nightlyBranch']

        if 'outputLibs' in repository:
            for outputLib in repository['outputLibs']:
                libraryName = BuildHelpers.getDynamicLibraryName(outputLib)

                ret = CmdHelpers.runExitIfFails(
                    "Copying library {}".format(libraryName),
                    "{exe} s3 --region eu-west-1 cp s3://orthanc.osimis.io/{target}/{project}/{version}/{file} {folder} --cache-control max-age=1".format(
                        exe = awsExecutable,
                        file = libraryName,
                        folder = artifactsPath,
                        target = getAwsConfigFolder(archi),
                        project = projectName,
                        version = branchName),
                    stdoutCallback = logger.info
                )

        if 'outputExes' in repository:
            for outputExe in repository['outputExes']:
                exeName = BuildHelpers.getExeName(outputExe)

                ret = CmdHelpers.runExitIfFails(
                    "Copying executable {}".format(exeName),
                    "{exe} s3 --region eu-west-1 cp s3://orthanc.osimis.io/{target}/{project}/{version}/{file} {folder} --cache-control max-age=1".format(
                        exe = awsExecutable,
                        file = exeName,
                        folder = artifactsPath,
                        target = getAwsConfigFolder(archi),
                        project = projectName,
                        version = branchName),
                    stdoutCallback = logger.info
                )

                # Add executable perm to executable in osx (eg. for Orthanc binary)
                if platform.system() == 'Darwin':
                    outputExePath = artifactsPath + '/' + exeName
                    mode = os.stat(outputExePath).st_mode
                    mode |= (mode & 0o444) >> 2  # copy R bits to X
                    os.chmod(outputExePath, mode)

    # include readme, configuration and startup scripts
    orthancDemoResourceFiles = os.path.join(scriptDir, 'orthancBuildResources')
    if platform.system() == 'Windows':
        shutil.copy(os.path.join(orthancDemoResourceFiles, 'readmeWin.txt'), os.path.join(artifactsPath, 'readme.txt'))
        shutil.copy(os.path.join(orthancDemoResourceFiles, 'configWin.json'), artifactsPath)
        shutil.copy(os.path.join(orthancDemoResourceFiles, 'startOrthanc.bat'), artifactsPath)
    else:
        shutil.copy(os.path.join(orthancDemoResourceFiles, 'readmeOSX.txt'), os.path.join(artifactsPath, 'readme.txt'))
        shutil.copy(os.path.join(orthancDemoResourceFiles, 'configOSX.json'), artifactsPath)
        shutil.copy(os.path.join(orthancDemoResourceFiles, 'startOrthanc.command'), artifactsPath)

    # compress to zip and upload zip to s3
    shutil.make_archive(base_name = artifactsPath,
                        format = 'zip',
                        root_dir = artifactsPath,
                        base_dir = None
                        )
    CmdHelpers.runExitIfFails('copying artifacts zip to s3',
                              '{0} s3 --region eu-west-1 cp {1} s3://orthanc.osimis.io{2}  --cache-control max-age=1'.format(awsExecutable,
                                                                                                  artifactsPath + '.zip',
                                                                                                  s3Path),
                              scriptDir, logger.info)

    # TODO: build a json doc with versions info that we can use in the orthanc.osimis.io index page



def build(branchName, archi, vsVersion, projectName, repository, skipCompilation = False, skipCheckout = False):
    if not 'build' in repository:
        logger.info('can not build {}, no build instruction'.format(projectName))

    build = repository['build']
    buildConfig = BuildHelpers.CONFIG_RELEASE
    buildFolder = os.path.join(scriptDir, repository['localName'], build['buildOutputFolder'])
    builder = getBuilder(archi, vsVersion)

    if not skipCheckout:
        logger.info('- Checking out {0}'.format(projectName))
        FileHelpers.makeSurePathDoesNotExists(repository['localName'])  # cleanup old build folder
        BuildHelpers.checkoutRepo(
            repoUrl = repository['url'],
            tool = repository['tool'],
            branchName = branchName,
            folder = repository['localName'],
            stdoutCallback = logger.info
        )

    if not skipCompilation:
        # --- build ---
        if build['type'] == 'cmake':

            cmakeListsFolderPath = os.path.join(scriptDir,
                                                repository['localName'],
                                                build['buildFromFolder'])
            thirdPartyDownloadsPath = os.path.join(cmakeListsFolderPath, 'ThirdPartyDownloads')

            FileHelpers.makeSurePathExists(thirdPartyDownloadsPath)
            # at the Labs, download of 3rd parties from Montefiore website sometimes fails => download them from s3
            CmdHelpers.run("Downloading ThirdPartyDownloads",
                           '{0} s3 --region eu-west-1 sync s3://orthanc.osimis.io/ThirdPartyDownloads {1}'.format(
                               awsExecutable, thirdPartyDownloadsPath), scriptDir, logger.info)

            FileHelpers.makeSurePathDoesNotExists(buildFolder)  # cleanup old build folder
            os.makedirs(buildFolder, exist_ok = True)
            os.chdir(buildFolder)
            shutil.rmtree(buildFolder, ignore_errors = True)
            ret = BuildHelpers.buildCMake(
                cmakeListsFolderPath = os.path.join(scriptDir, repository['localName'],
                                                    build['buildFromFolder']),
                buildFolderPath = buildFolder,
                cmakeTargetName = build['cmakeTarget'],
                cmakeArguments = build['cmakeOptions'],
                builder = builder,
                config = buildConfig,
                cmakeTargetsOSX = build['cmakeTargetsOSX'] if 'cmakeTargetsOSX' in build else None
            )

            if ret != 0:
                logger.error('Error while Building {} with {} on branch {}'.format(projectName, builder, branchName))
                exit(ret)

    os.chdir(os.path.join(buildFolder, BuildHelpers.getOutputFolder(builder, buildConfig)))

    if not skipCompilation:
        # --- run unit tests ---
        if 'unitTestsExe' in build and build['unitTestsExe'] is not None:
            logger.info("Running unit tests")

            CmdHelpers.runExitIfFails("Running unit tests", BuildHelpers.getExeCommandName(build['unitTestsExe']),
                                      stdoutCallback = logger.info)

    # --- publish to AWS ---
    if 'outputLibs' in repository:
        for outputLib in repository['outputLibs']:
            libraryName = BuildHelpers.getDynamicLibraryName(outputLib)

            ret = CmdHelpers.runExitIfFails(
                "Copying library {}".format(libraryName),
                "{exe} s3 --region eu-west-1 cp {file} s3://orthanc.osimis.io/{target}/{project}/{version}/ --cache-control max-age=1".format(
                    exe = awsExecutable,
                    file = libraryName,
                    target = getAwsConfigFolder(archi),
                    project = projectName,
                    version = branchName),
                stdoutCallback = logger.info
            )

    if 'outputExes' in repository:
        for outputExe in repository['outputExes']:
            exeName = BuildHelpers.getExeName(outputExe)

            ret = CmdHelpers.runExitIfFails(
                "Copying executable {}".format(exeName),
                "{exe} s3 --region eu-west-1 cp {file} s3://orthanc.osimis.io/{target}/{project}/{version}/ --cache-control max-age=1".format(
                    exe = awsExecutable,
                    file = exeName,
                    target = getAwsConfigFolder(archi),
                    project = projectName,
                    version = branchName),
                stdoutCallback = logger.info
            )


if __name__ == '__main__':
    parser = argparse.ArgumentParser()

    subparsers = parser.add_subparsers(dest = 'action')

    buildParser = subparsers.add_parser('build', help = 'builds an Orthanc plugin or Orthanc')
    publishParser = subparsers.add_parser('publish', help = 'package an OSX/Win release of Orthanc and its plugins')

    buildParser.add_argument('--branchName',
                             help = 'name of the branch to build (if you have not provided stable/nightly)')
    buildParser.add_argument('--vsVersion', help = 'Visual studio version to use {2013,2015}', default = '2015')
    buildParser.add_argument('--skipCompilation', help = 'actually skip the compilation phase', action = 'store_true',
                             default = False)
    buildParser.add_argument('--skipCheckout', help = 'actually skip the SCM checkout phase', action = 'store_true',
                             default = False)
    buildParser.add_argument('--archi', help = 'name of the architecture to build {win32,win64}', default = 'win64')
    buildParser.add_argument('-u', '--user', required = False, help = 'Bitbucket username (if not using SSH key)')
    buildParser.add_argument('-p', '--password', required = False, help = 'Bitbucket password (if not using SSH key)')

    for repositoryName in repositories.keys():
        buildParser.add_argument('--{0}'.format(repositoryName), action = 'store_true',
                                 help = 'Build {0}'.format(repositoryName), required = False)

    publishParser.add_argument('--archi', help = 'name of the architecture to build {win32,win64}', default = 'win64')

    parser.add_argument('config', choices = ['nightly', 'stable'])

    args = parser.parse_args()

    if args.action == 'publish':
        packageOrthancAndPlugins(args.config, args.archi)
    elif args.action == 'build':
        # walk through all repositories and build them
        for projectName in repositories.keys():
            if (projectName in args and getattr(args, projectName) == True):
                repository = repositories[projectName]
                if platform.system() not in repository['platforms']:
                    logger.info('Skipping {name}, not to be built for this platform'.format(name = projectName))
                else:
                    if args.config is not None:
                        if args.config == 'nightly':
                            branchName = repository['nightlyBranch']
                        else:
                            branchName = repository['stableBranch']
                    elif args.branchName is not None:
                        branchName = args.branchName
                    else:
                        logger.error('please specify a --branchName or --stable/--nightly')
                        exit(1)

                    logger.info("+++ Building {name}, branch {branchName} +++".format(name = projectName,
                                                                                      branchName = branchName))
                    build(branchName = branchName,
                          archi = args.archi,
                          vsVersion = args.vsVersion,
                          projectName = projectName,
                          repository = repository,
                          skipCompilation = args.skipCompilation,
                          skipCheckout = args.skipCheckout)

