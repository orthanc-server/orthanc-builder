# Description

This repo contains build instructions for the following components:

- the osimis/orthanc Dockerhub image
- the Windows installer
- the OSX package (zip with exe and plugins, contains the stable and unstable versions)
- the Windows package (zip with exe and plugins, contains the stable and unstable versions)

## Orthanc-pro images

From July 1st 2020, the osimis/orthanc-pro image has gone [private](https://www.osimis.io/en/services.html#cloud-plugins).  Since it highly depends
on the `osimis/orthanc` image, it is builder code is included as a private git submodule in the `docker/orthanc-pro-builder` folder.

Note for Osimis developers: you might have to run a `git submodule update --init` command the first time you clone the repo.

To release the Windows installers, once you have updated all versions (CHANGE_VERSION_WIN_INSTALLER), launch `./ciBuildWindowsInstaller.sh`

To release the OSX package, once you have updated all version (CHANGE_VERSION_OSX), launch `./buildOrthancOSX.sh`
