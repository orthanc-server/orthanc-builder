# Description

This repo contains build instructions for the following components:
- the osimis/orthanc Dockerhub image
- the osimis/orthanc-pro Dockerhub image
- the Windows installer
- the OSX package (zip with exe and plugins, contains the stable and unstable versions)
- the Windows package (zip with exe and plugins, contains the nightly-unstable versions)

The docker images and Windows installers are official releases and shall be versioned consistently (they should share the same package numbers and same content).  These packages are numberd by YY.M[.r] where YY is the year, M is the month and r is the release counter for this month.  When r is zero, it is not included in Docker images and in communication.

# Upgrading packages

This procedure is still very manual...  Each time you want to release a new package (which means you'll upgrade the version of at least one component):
- search for `CHANGE_VERSION` in the whole repo and look for lines containing the component(s) you're upgrading -> upgrade the versions
- search for `CHANGE_VERSION` in the whole repo and look for the package version numbers -> upgrade with YY.M[.r]
- update the WindowsInstaller/Resources/README.txt with the new version numbers
- update the docker/README-dockerhub.txt with the new version numbers (keep the previous version package list in the readme)
- build the orthanc-builder image: `ciBuildOrthancBuilderImage.sh --no-cache`
- build the osimis/orthanc image: `ciBuildOsimisOrthancDockerImage.sh --no-cache`
- build the osimis/orthanc-pro image: `ciBuildOsimisOrthancProDockerImage.sh --no-cache`
- make sure the Docker image can be started `docker run -rm -P 8042:8042 osimis/orthanc:YY.M`
- commit your changes
- tag the repo with the package version `git tag -a YY.M -m "YY.M"`
- push to bitbucket (including the tag: `git push --tags` followed by `git push`)
- trigger a build of the Windows Installer
- download the Windows Installer and perform a smoke test (make sure it starts correctly)
- notify S. Jodogne that a new Windows Installer is available
- tag the docker images with `latest`: `docker tag osimis/orthanc:YY.M osimis/orthanc:latest` and `docker tag osimis/orthanc-pro:YY.M osimis/orthanc-pro:latest`
- push the 4 images to Dockerhub: `docker push [osimis/orthanc:YY.M osimis/orthanc:latest osimis/orthanc-pro:YY.M osimis/orthanc-pro:latest]`
- connect to Dockerhub and update the documentation manually by copy/pasting the content of `docker/README-dockerhub.txt` into the project description

