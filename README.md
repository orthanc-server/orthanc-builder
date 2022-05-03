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
- [OSX package (Universal)](https://orthanc.osimis.io/osx/releases/Orthanc-OSX-master-unstable.zip)


**Notes**: 

- you can use this repo to build `linux/arm64` docker images but we are currently not able to build them on our build slaves because, with QEMU emulation, a build would take more than 12 hours which is the limit of github.  Simply use `./local-build.sh platform=linux/arm64` to build these images.
- to build stable Docker images locally, use `./local-build.sh skipCommitChecks=1`
- The OSX package does not contain the WSI plugin that can currently be built only for Intel processors.

# Continuous Builds

- OSX stable/unstable binaries and packages are rebuilt every night (if needed) and on every commit
- Window stable installer is rebuilt at every commit
- Docker stable and unstable images are rebuilt every night and on every commit
- Integration tests are run for every Docker build

# Troubleshooting

- if an OSX build fails, you may connect to the build slave thanks to `tmate`.  Access is limited to approved actors with their SSH Github key.
- sometimes, the `test_incoming_jpeg (Tests.Orthanc)` test fails.  Retrying the job usually solve the issue (TODO investigate)

# Contributions

You must sign a [CLA](https://en.wikipedia.org/wiki/Contributor_License_Agreement) before we are able to accept your contributions/pull-requests.  

