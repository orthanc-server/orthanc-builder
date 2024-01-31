# Description

This repo contains build instructions for the following components:

- the `orthancteam/orthanc` Docker image
- the Windows installer
- the MacOS package (zip with Orthanc executable and plugins)

The Docker image is rebuilt from scratch (Orthanc and all its plugins are compiled during the build process).
Windows Installer and MacOS package are collecting build artifacts from the Orthanc buildbot server.

# Where to find the releases ?

## stable releases

- [Docker image (linux/amd64)](https://hub.docker.com/r/orthancteam/orthanc)
- [Windows 64 bits installer](https://orthanc.uclouvain.be/downloads/windows-64/installers/index.html)
- [Windows 32 bits installer](https://orthanc.uclouvain.be/downloads/windows-32/installers/index.html)
- [MacOS package (Universal)](https://orthanc.uclouvain.be/downloads/macos/packages/universal/index.html)

## unstable releases (nightly builds)

- [Docker image (linux/amd64)](https://hub.docker.com/r/orthancteam/orthanc-unstable) (`orthancteam/orthanc-unstable:master` image)
<!-- - [Windows 64 bits installer](https://orthanc.osimis.io/win-installer/OrthancInstaller-Win64-master.exe) these are actually 'stable'!-->
<!-- - [Windows 32 bits installer](https://orthanc.osimis.io/win-installer/OrthancInstaller-Win32-master.exe) these are actually 'stable'!-->
- [MacOS package (Universal)](https://public-files.orthanc.team/MacOS-packages/Orthanc-MacOS-master-unstable.zip)


**Notes**: 

- to build stable Docker images locally, use `./local-build.sh skipCommitChecks=1`.  This produces `orthancteam/orthanc:current` images.
- The MacOS package does not contain the WSI plugin that can currently be built only for Intel processors.

## building ARM 64 docker images

You can use this repo to build `linux/arm64` docker images but we are currently not able to build them on our build slaves because, with QEMU emulation, a build would take more than 12 hours which is the limit of github actions.

Hereunder, you'll find the full instructions to build ARM64 docker images on MacOS (note: this won't build Azure & Google object-storage plugins).  Note, the StoneViewer build can last very long (multiple hours) because it is using an emulated container to build the WebAssembly code:
```
brew install jq
brew install hg

git clone https://github.com/orthanc-server/orthanc-builder.git
cd orthanc-builder
./local-build.sh version=stable platform=linux/arm64 image=normal
```

This produces an image `orthancteam/orthanc:current`.


# Continuous Builds

- MacOS stable/unstable binaries and packages are rebuilt every night (if needed) and on every commit
- Windows stable installers are rebuilt at every commit, they are available at:
  - [https://public-files.orthanc.team/tmp-builds/win-installer/OrthancInstaller-Win64-master.exe](https://public-files.orthanc.team/tmp-builds/win-installer/OrthancInstaller-Win64-master.exe)
- Docker stable and unstable images are rebuilt every night and on every commit of this repo, they are available as:
  - `orthancteam/orthanc:master`
  - `orthancteam/orthanc-unstable:master`
- Integration tests are run for every Docker build

# Troubleshooting (for dev)

- if a MacOS build fails, you may connect to the build slave thanks to `tmate`.  Access is limited to approved actors with their SSH Github key.

# Contributions

You must sign a [CLA](https://en.wikipedia.org/wiki/Contributor_License_Agreement) before we are able to accept your contributions/pull-requests.  

