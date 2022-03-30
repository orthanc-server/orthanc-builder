# Description

This repo contains build instructions for the following components:

- the `osimis/orthanc` Docker image
- the Windows installer
- the OSX package (zip with Orthanc executable and plugins)

The Docker image is rebuilt from scratch (Orthanc and all its plugins are compiled during the build process).
Windows Installer and OSX package are collecting build artifacts from the Orthanc buildbot server.

# Where to find the releases ?

- [Docker image (linux/amd64)](https://hub.docker.com/r/osimis/orthanc)
- [Windows 64 bits installer](https://orthanc.osimis.io/win-installer/OrthancInstaller-Win64-latest.exe)
- [Windows 32 bits installer](https://orthanc.osimis.io/win-installer/OrthancInstaller-Win32-latest.exe)
- [OSX package (Universal)](https://orthanc.osimis.io/osx/stable/orthancAndPluginsOSX.stable.zip)

**Notes**: 
- you can use this repo to build `linux/arm64` docker images but we are currently not able to build them on our build slaves because, with QEMU emulation, a build would take more than 12
  hours which is the limit of github.
- the OSX binaries are all Universal binaries except for the OsimisViewer
  and WSI plugins that are Intel binaries only.


# Contributions

You must sign a [CLA](https://en.wikipedia.org/wiki/Contributor_License_Agreement) before we are able to accept your contributions/pull-requests.  

