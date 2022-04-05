# Description

This repo contains build instructions for the following components:

- the `osimis/orthanc` Docker image
- the Windows installer
- the OSX package (zip with Orthanc executable and plugins)

The Docker image is rebuilt from scratch (Orthanc and all its plugins are compiled during the build process).
Windows Installer and OSX package are collecting build artifacts from the Orthanc buildbot server.

# Where to find the releases ?

## stable releases

- [Docker image (linux/amd64)](https://hub.docker.com/r/osimis/orthanc)
- [Windows 64 bits installer](https://orthanc.osimis.io/win-installer/OrthancInstaller-Win64-latest.exe)
- [Windows 32 bits installer](https://orthanc.osimis.io/win-installer/OrthancInstaller-Win32-latest.exe)
- [OSX package (Universal)](https://orthanc.osimis.io/osx/stable/orthancAndPluginsOSX.stable.zip)

## unstable releases (nightly builds)

- [Docker image (linux/amd64)](https://hub.docker.com/r/osimis/orthanc) (`master` or `dev` tags)
<!-- - [Windows 64 bits installer](https://orthanc.osimis.io/win-installer/OrthancInstaller-Win64-unstable.exe) -->
<!-- - [Windows 32 bits installer](https://orthanc.osimis.io/win-installer/OrthancInstaller-Win32-unstable.exe) -->
<!-- - [OSX package (Universal)](https://orthanc.osimis.io/osx/releases/orthancAndPluginsOSX.unstable.zip) -->


**Notes**: 

- you can use this repo to build `linux/arm64` docker images but we are currently not able to build them on our build slaves because, with QEMU emulation, a build would take more than 12 hours which is the limit of github.  Simply use `./local-build.sh platform=linux/arm64` to build these images.
- to build stable Docker images locally, use `./local-build.sh skipCommitChecks=1`
- The OSX package does not contain the WSI plugin that can currently be built only for Intel processors.

# Continuous Builds

- OSX stable/unstable binaries are rebuilt every night (if needed) (`nightly-osx-branch-builds.yml`)
- OSX unstable package is rebuilt every night (`nightly-unstable-packages.yml`)
- OSX stable package is rebuilt at every commit (`all-builds.yml`)
- Window stable installer is rebuilt at every commit (`all-builds.yml`)
<!-- TODO - Window unstable installer is rebuilt every night (`all-builds.yml`) -->
- Docker stable image is rebuilt at every commit (`all-builds.yml`)
- Docker unstable image is rebuilt every night (`nightly-unstable-packages.yml`)
- Integration tests are run for every Docker build

# Troubleshooting

- sometimes, the Github runner might run out of space (especially when if you change the base Debian image and it needs to rebuild everything).  You should
  relaunch the build.  The second build will benefit from the Docker cache and should succeed.
- if an OSX build fails, you may connect to the build slave thanks to `tmate`.  Access is limited to approved actors with their SSH Github key.

# Contributions

You must sign a [CLA](https://en.wikipedia.org/wiki/Contributor_License_Agreement) before we are able to accept your contributions/pull-requests.  

