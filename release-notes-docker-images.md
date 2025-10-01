> [!NOTE]  
> These release notes apply to both the [orthancteam/orthanc](https://orthanc.uclouvain.be/book/users/docker-orthancteam.html) 
> Docker images and the [Windows installer](https://orthanc.uclouvain.be/downloads/windows-64/installers/index.html) 
> that share the same numbering scheme.


> [!TIP]
> Starting from the `22.6.1` release, we are providing 2 types of Docker images:
>  - the default image with the usual tag: e.g `orthancteam/orthanc:22.6.1`
>  - the full image with a e.g `orthancteam/orthanc:22.6.1-full` tag
>
> The default image is suitable for 99.9% of users.
>
> You should use the full image only if you need to use one of these:
>  - the Azure Blob storage plugin
>  - the Google Cloud storage plugin
>  - the ODBC plugin with SQL Server (msodbcsql18 is preinstalled)
>  - the Java plugin (from version 24.6.2)
>
> Only the default tags are listed here.  You just need to append `-full` for the full image.
>
> Starting from `24.3.5`, the docker images are available for `linux/amd64` and `linux/arm64`.


25.10.0
-------

- upgraded Orthanc Explorer 2 plugin to [1.9.2](https://github.com/orthanc-server/orthanc-explorer-2/blob/master/release-notes.md)
- upgraded Kitware VolView plugin to [1.3](https://orthanc.uclouvain.be/hg/orthanc-volview/file/default/NEWS)


25.9.2
------

- upgraded Advanced Storage plugin [0.2.2](https://github.com/orthanc-server/orthanc-advanced-storage/blob/master/release-notes.md)


25.9.1
------

- upgraded Advanced Storage plugin [0.2.1](https://github.com/orthanc-server/orthanc-advanced-storage/blob/master/release-notes.md)
- DOCKER: ugraded base image to `ubuntu:noble-20250910`


25.9.0
------

- upgraded Orthanc Explorer 2 plugin to [1.9.1](https://github.com/orthanc-server/orthanc-explorer-2/blob/master/release-notes.md)
- upgraded Advanced Storage plugin [0.2.0](https://github.com/orthanc-server/orthanc-advanced-storage/blob/master/release-notes.md)
- DOCKER: ugraded base image to `ubuntu:noble-20250805`


25.8.2
------

- upgraded Java plugin to [2.0](https://orthanc.uclouvain.be/hg/orthanc-java/file/default/NEWS)
- DOCKER: reduced the size of Docker images by a factor of 3.


25.8.1
------

- upgraded DICOMweb plugin to [1.21](https://orthanc.uclouvain.be/hg/orthanc-dicomweb/file/default/NEWS)


25.8.0
------

- upgraded Orthanc to [1.12.9](https://orthanc.uclouvain.be/hg/orthanc/file/default/NEWS)
- upgraded PostgreSQL plugins to [9.0](https://orthanc.uclouvain.be/hg/orthanc-databases/file/default/PostgreSQL/NEWS)
- upgraded OHIF plugin to [1.7](https://orthanc.uclouvain.be/hg/orthanc-ohif/file/default/NEWS) featuring OHIF v3.11.0.
- upgraded advanced authorization plugin to [0.10.1](https://orthanc.uclouvain.be/hg/orthanc-authorization/file/default/NEWS)
- upgraded Orthanc Explorer 2 plugin to [1.9.0](https://github.com/orthanc-server/orthanc-explorer-2/blob/master/release-notes.md)
- upgraded Python plugin to [6.0](https://orthanc.uclouvain.be/hg/orthanc-python/file/default/NEWS)
- DOCKER: ugraded base image to `ubuntu:noble-20250714`
- DOCKER: upgraded StoneWebViewer to 2.6+266b0b912c35


25.7.0
------

- upgraded advanced authorization plugin to [0.9.4](https://orthanc.uclouvain.be/hg/orthanc-authorization/file/default/NEWS)
- DOCKER: ugraded base image to `ubuntu:noble-20250619`


25.6.4
------

- upgraded Advanced Storage plugin [0.1.1](https://github.com/orthanc-server/orthanc-advanced-storage/blob/master/release-notes.md)


25.6.3
------

- upgraded PostgreSQL plugins to [8.0](https://orthanc.uclouvain.be/hg/orthanc-databases/file/default/PostgreSQL/NEWS)
- added new [Advanced Storage](https://orthanc.uclouvain.be/book/plugins/advanced-storage.html) plugin [0.1.0](https://github.com/orthanc-server/orthanc-advanced-storage/blob/master/release-notes.md)
- upgraded Orthanc Explorer 2 plugin to [1.8.5](https://github.com/orthanc-server/orthanc-explorer-2/blob/master/release-notes.md)
- DOCKER: OE2 is now the default Orthanc UI.


25.6.2
------

- upgraded Orthanc to [1.12.8](https://orthanc.uclouvain.be/hg/orthanc/file/default/NEWS)

25.6.0
------

- upgraded Orthanc Explorer 2 plugin to [1.8.4](https://github.com/orthanc-server/orthanc-explorer-2/blob/master/release-notes.md)
- upgraded advanced authorization plugin to [0.9.3](https://orthanc.uclouvain.be/hg/orthanc-authorization/file/default/NEWS)
- DOCKER: ugraded base image to `ubuntu:noble-20250529`


25.5.1
------

- upgraded DICOMweb plugin to [1.20](https://orthanc.uclouvain.be/hg/orthanc-dicomweb/file/default/NEWS)


25.5.0
------

- upgraded OHIF plugin to [1.6](https://orthanc.uclouvain.be/hg/orthanc-ohif/file/default/NEWS) featuring
  OHIF v3.10.1.
- upgraded DICOMweb plugin to [1.19](https://orthanc.uclouvain.be/hg/orthanc-dicomweb/file/default/NEWS)
- upgraded Orthanc Explorer 2 plugin to [1.8.3](https://github.com/orthanc-server/orthanc-explorer-2/blob/master/release-notes.md)
- upgraded advanced authorization plugin to [0.9.2](https://orthanc.uclouvain.be/hg/orthanc-authorization/file/default/NEWS)
- upgraded Orthanc Web viewer plugin to [2.10](https://orthanc.uclouvain.be/hg/orthanc-webviewer/file/default/NEWS)
- DOCKER: ugraded base image to `ubuntu:noble-20250404`


25.4.2
------

- upgraded WSI plugin to [3.2](https://orthanc.uclouvain.be/hg/orthanc-wsi/file/default/NEWS)
- DOCKER: fix missing python .so files


25.4.1
------

- DOCKER: ugraded base image to `ubuntu:noble-20250127` which means that:
  - python has been upgraded to 3.12
  - <span style="color: #B44">**NOTE: python plugins are not working in this version**</span> -> you should update to 25.4.2
- DOCKER: reduced the number of installed Debian packages by using `--no-install-recommends` during installation.
  As a consequence, `python3-pip` might not be able to compile C code when installing some python packages.
- Docker: upgraded Google cloud object-storage plugin to [2.5.1](https://orthanc.uclouvain.be/hg/orthanc-object-storage/file/default/NEWS)


25.4.0
------

- upgraded Orthanc to [1.12.7](https://orthanc.uclouvain.be/hg/orthanc/file/default/NEWS)
- upgraded Orthanc Explorer 2 plugin to [1.8.2](https://github.com/orthanc-server/orthanc-explorer-2/blob/master/release-notes.md)
- upgraded WSI plugin to [3.1](https://orthanc.uclouvain.be/hg/orthanc-wsi/file/OrthancWSI-3.1/NEWS)
- upgraded advanced authorization plugin to [0.9.1](https://orthanc.uclouvain.be/hg/orthanc-authorization/file/default/NEWS)
- DOCKER: upgraded StoneWebViewer to 2.6+e90ddb89c3ae
- DOCKER: upgraded Kitware VolView plugin to [1.2+ 4c850b84e90f](https://orthanc.uclouvain.be/hg/orthanc-volview/file/default/NEWS)
- DOCKER: upgraded base image to `debian:bookworm-20250317-slim`.  Note: this is the last release using Debian Bookworm as the
  base image.  Following releases will use Ubuntu based images to benefit from more frequent updates.


25.2.0
------

- upgraded PostgreSQL plugins to [7.2](https://orthanc.uclouvain.be/hg/orthanc-databases/file/default/PostgreSQL/NEWS)
- upgraded Orthanc Explorer 2 plugin to [1.8.0](https://github.com/orthanc-server/orthanc-explorer-2/blob/master/release-notes.md)
- upgraded advanced authorization plugin to [0.9.0](https://orthanc.uclouvain.be/hg/orthanc-authorization/file/default/NEWS)
- DOCKER upgraded Kitware VolView plugin to [1.2+e2fd60bf5a09](https://orthanc.uclouvain.be/hg/orthanc-volview/file/default/NEWS)
- DOCKER: upgraded base image to `debian:bookworm-20250224-slim`


25.1.1
------

- upgraded Orthanc to [1.12.6](https://orthanc.uclouvain.be/hg/orthanc/file/default/NEWS)
- upgraded Orthanc Explorer 2 plugin to [1.7.1](https://github.com/orthanc-server/orthanc-explorer-2/blob/master/release-notes.md)
- upgraded PostgreSQL plugins to [7.1](https://orthanc.uclouvain.be/hg/orthanc-databases/file/default/PostgreSQL/NEWS)
- upgraded python plugin to [5.0](https://orthanc.uclouvain.be/hg/orthanc-python/file/default/NEWS)
- upgraded advanced authorization plugin to [0.8.2](https://orthanc.uclouvain.be/hg/orthanc-authorization/file/default/NEWS)
- DOCKER: upgraded StoneWebViewer to 2.6+115628b0651d


25.1.0
------

- upgraded OHIF plugin to [1.5](https://orthanc.uclouvain.be/hg/orthanc-ohif/file/OrthancOHIF-1.5/NEWS)
- upgraded Kitware VolView plugin to [1.2](https://orthanc.uclouvain.be/hg/orthanc-volview/file/OrthancVolView-1.2/NEWS)
- upgraded WSI plugin to [3.0](https://orthanc.uclouvain.be/hg/orthanc-wsi/file/OrthancWSI-3.0/NEWS)
- DOCKER: plugins added during the `-full` build process are now owned by `orthanc` user too.
- DOCKER: upgraded base image to `debian:bookworm-20250113-slim`


24.12.0
-------

- upgraded Orthanc to [1.12.5](https://orthanc.uclouvain.be/hg/orthanc/file/default/NEWS)
- upgraded PostgreSQL plugins to [7.0](https://orthanc.uclouvain.be/hg/orthanc-databases/file/default/PostgreSQL/NEWS)
- upgraded Orthanc Explorer 2 plugin to [1.7.0](https://github.com/orthanc-server/orthanc-explorer-2/blob/master/release-notes.md)
- upgraded DICOMweb plugin to [1.18](https://orthanc.uclouvain.be/hg/orthanc-dicomweb/file/default/NEWS)
- upgraded AWS S3 object-storage plugin to [2.5.0](https://orthanc.uclouvain.be/hg/orthanc-object-storage/file/default/NEWS)
- upgraded ODBC plugin to [1.3](https://orthanc.uclouvain.be/hg/orthanc-databases/file/default/Odbc/NEWS)
- DOCKER: upgraded base image to `debian:bookworm-20241202-slim`
- DOCKER: in `unstable` images, the plugin version names now contain the commitId.
- DOCKER: fix wrong version of OHIF viewer (now 3.9.1)


24.11.0
-------

- upgraded OHIF plugin to [1.4](https://orthanc.uclouvain.be/hg/orthanc-ohif/file/OrthancOHIF-1.4/NEWS)


24.10.3
-------

- DOCKER: upgraded base image to `debian:bookworm-20241016-slim`
- DOCKER: upgraded StoneWebViewer to 2.6+c5f94c10cd61


24.10.2
-------

- upgraded WSI plugin to [2.1](https://orthanc.uclouvain.be/hg/orthanc-wsi/file/OrthancWSI-2.1/NEWS)


24.10.1
-------

- upgraded Orthanc Explorer 2 plugin to [1.6.4](https://github.com/orthanc-server/orthanc-explorer-2/blob/master/release-notes.md)
- DOCKER: upgraded base image to `debian:bookworm-20240926-slim`
- DOCKER: in `unstable` images, the plugin version names now contain the commitId.


24.9.1
------

- upgraded Orthanc Explorer 2 plugin to [1.6.2](https://github.com/orthanc-server/orthanc-explorer-2/blob/master/release-notes.md)
- DOCKER: upgraded base image to `debian:bookworm-20240904-slim`


24.8.3
------

- upgraded Stone Web viewer plugin to [2.6](https://orthanc.uclouvain.be/hg/orthanc-stone/file/tip/Applications/StoneWebViewer/NEWS)


24.8.2
------

- upgraded Orthanc Explorer 2 plugin to [1.6.1](https://github.com/orthanc-server/orthanc-explorer-2/blob/master/release-notes.md)
- DOCKER: upgraded base image to `debian:bookworm-20240812-slim`
- DOCKER: upgraded StoneWebViewer to 2.5+c23eef785569


24.8.1
------

- upgraded Orthanc Explorer 2 plugin to [1.6.0](https://github.com/orthanc-server/orthanc-explorer-2/blob/master/release-notes.md)
- upgraded GDCM plugin to [1.8](https://orthanc.uclouvain.be/hg/orthanc-gdcm/file/default/NEWS)
- WIN-INSTALLER: The Osimis viewer is not installed anymore by default (but it can still be selected during
  the installation process).
- WIN-INSTALLER: commented out the "Host" value of the default dicomweb.json that was incorrect.
- DOCKER: upgraded base image to `debian:bookworm-20240722-slim`


24.7.3
------

- upgraded OHIF plugin to [1.3](https://orthanc.uclouvain.be/hg/orthanc-ohif/file/default/NEWS)


24.7.2
------

- upgraded python plugin to [4.3](https://orthanc.uclouvain.be/hg/orthanc-python/file/default/NEWS)


24.7.1
------

- upgraded Orthanc Explorer 2 plugin to [1.5.1](https://github.com/orthanc-server/orthanc-explorer-2/blob/master/release-notes.md)
- upgraded advanced authorization plugin to [0.8.1](https://orthanc.uclouvain.be/hg/orthanc-authorization/file/default/NEWS)


24.7.0
------

- upgraded Orthanc Explorer 2 plugin to [1.5.0](https://github.com/orthanc-server/orthanc-explorer-2/blob/master/release-notes.md)
- upgraded advanced authorization plugin to [0.8.0](https://orthanc.uclouvain.be/hg/orthanc-authorization/file/default/NEWS)


24.6.3
------

- upgraded AWS S3 object-storage plugin to [2.4.0](https://orthanc.uclouvain.be/hg/orthanc-object-storage/file/default/NEWS)
- WIN-INSTALLER: added AWS S3 plugin


24.6.2
------

- added [Java plugin 1.0](https://orthanc.uclouvain.be/book/plugins/java.html) to the `-full` image only
  - DOCKER: new env var "JAVA_PLUGIN_ENABLED" to enable the Java plugin
  - DOCKER: The Java SDK is installed on the `-full` image
  - DOCKER: The `OrthancJavaSDK.jar` is stored in `/java`
  - DOCKER: [link to a sample Java setup](https://github.com/orthanc-server/orthanc-setup-samples/tree/master/docker/java)
- upgraded STL plugin to [1.2](https://orthanc.uclouvain.be/hg/orthanc-stl/file/default/NEWS)
- DOCKER: upgraded base image to `debian:bookworm-20240612-slim`
- WIN-INSTALLER: added Java plugin; not installed by default.


24.6.1
------

- upgraded Orthanc to [1.12.4](https://orthanc.uclouvain.be/hg/orthanc/file/default/NEWS)
- upgraded DICOMweb plugin to [1.17](https://orthanc.uclouvain.be/hg/orthanc-dicomweb/file/default/NEWS)
- upgraded Orthanc Explorer 2 plugin to [1.4.1](https://github.com/orthanc-server/orthanc-explorer-2/blob/master/release-notes.md)
- upgraded MySQL plugin to [5.2](https://orthanc.uclouvain.be/hg/orthanc-databases/file/default/MySQL/NEWS)
- upgraded STL plugin to [1.1](https://orthanc.uclouvain.be/hg/orthanc-stl/file/default/NEWS)
- DOCKER: upgraded base image to `debian:bookworm-20240513-slim`


24.5.1
------

- upgraded Orthanc Explorer 2 plugin to [1.4.0](https://github.com/orthanc-server/orthanc-explorer-2/blob/master/release-notes.md)
- upgraded python plugin to [4.2](https://orthanc.uclouvain.be/hg/orthanc-python/file/default/NEWS)
- upgraded advanced authorization plugin to [0.7.2](https://orthanc.uclouvain.be/hg/orthanc-authorization/file/default/NEWS)


24.5.0
------

- upgraded GDCM plugin to 1.7
- DOCKER: added non standard env var `ORTHANC__POSTGRESQL__ENABLE_VERBOSE_LOGS`
- DOCKER ARM64 image: fixed OHIF and VolView plugins that were acutally missing.


24.4.0
------

- added STL plugin 1.0
- DOCKER: upgraded base image to `debian:bookworm-20240408-slim`


24.3.5
------

First release supporting the linux/arm64 platform !

Due to the orthanc.osimis.io server being shut down, we had to release many
old plugins that were still referencing this server in their build process.  
Most of them actually do not contain any functional changes compared with the previous release.

- upgraded neuroimaging plugin 1.1 (only a minor [functional change](https://orthanc.uclouvain.be/hg/orthanc-neuro/file/default/NEWS))
- upgraded Orthanc Web viewer plugin 2.9 (no functional changes)
- upgraded transfers accelerator plugin 1.5 (no functional changes)
- upgraded server indexer plugin 1.1 (no functional changes)
- upgraded TCIA plugin to 1.2 (no functional changes)


24.3.4
------

- upgraded Orthanc Explorer 2 plugin to [1.3.0](https://github.com/orthanc-server/orthanc-explorer-2/blob/master/release-notes.md)
- upgraded advanced authorization plugin to [0.7.1](https://orthanc.uclouvain.be/hg/orthanc-authorization/file/default/NEWS)
- upgraded PostgreSQL plugins to [6.2](https://orthanc.uclouvain.be/hg/orthanc-databases/file/default/PostgreSQL/NEWS)
- DOCKER: upgraded base image to `debian:bookworm-20240311-slim`


24.3.3
------

> [!WARNING]
> - DOCKER: upgraded base image to `debian:bookworm-20240211-slim` which implies:
>   - python has been upgraded to 3.11.
>   - when using `pip install ...`, you may need to add the `--break-system-package` argument
>     since the system python is now considered as an `external environment`


24.3.2
------

- upgraded ODBC plugin to [1.2](https://orthanc.uclouvain.be/hg/orthanc-databases/file/default/Odbc/NEWS)


24.3.1
------

- DOCKER: upgraded the [healthcheck probe](https://orthanc.uclouvain.be/book/users/docker-orthancteam.html#healthcheck-probe).  It is now calling `/changes` instead of `/system` 
  because `/system` is not testing the DB connection while `/changes` does.
- DOCKER: upgraded base image to `bullseye-20240211-slim`


24.2.3
------

> [!CAUTION]
> **_BUG:_** these Docker images actually contained the mainline versions and not the official releases !!!!
- upgraded Orthanc Explorer 2 plugin to [1.2.2](https://github.com/orthanc-server/orthanc-explorer-2/blob/master/release-notes.md)
- upgraded advanced authorization plugin to [0.7.0](https://orthanc.uclouvain.be/hg/orthanc-authorization/file/tip/NEWS)


24.2.2
------

- upgraded PostgreSQL plugins to [6.1](https://orthanc.uclouvain.be/hg/orthanc-databases/file/tip/PostgreSQL/NEWS)


Previous versions (old txt release notes)
-----------------

```
24.2.1 :  - upgraded PostgreSQL plugins to 6.0
24.2.0 :  - now publishing the tagged images to orthancteam/orthanc
            and the pre-release images to orthancteam/orthanc-pre-release
          - from now on, the images are not published anymore on osimis/orthanc
          - upgraded Orthanc to 1.12.3
          - upgraded base image to debian:bullseye-20240110-slim
          - upgraded StoneWebViewer to 2.5+c23eef785569 (Docker images only)
24.1.2 :  - WIN-INSTALLER: by default, do not install any python plugin (bug introduced in 24.1.0)
          - upgraded Osimis Web Viewer to 1.4.3 (security fix)
            reminder: the Osimis Web Viewer is deprecated, it's time to move to another viewer
            like the StoneWebViewer that is equivalent.
24.1.0:   - upgraded GDCM plugin to 1.6
          - upgraded OHIF plugin to 1.2
          - upgraded Orthanc Explorer 2 plugin to 1.2.1
          - WIN-INSTALLER: improved the categories in the Windows installers
23.12.1:  - WIN-INSTALLER: reverted old paths in Windows installers to allow reinstall/uninstall 
                           (bug introduced in 23.11.1)
23.12.0:  - upgraded Orthanc to 1.12.2
          - upgraded DICOMweb plugin to 1.16
          - upgraded Orthanc Explorer 2 plugin to 1.2.0
          - upgraded advanced authorization plugin to 0.6.2
          - upgraded StoneWebViewer to 2.5+5970030a413c (Docker images only)
          - upgraded object-storage plugins to 2.3.1
          - upgraded base image to debian:bullseye-20231120-slim
23.11.1:  - upgraded OHIF plugin to 1.1
          - upgraded base image to debian:bullseye-20231030-slim
23.11.0:  - upgraded advanced authorization plugin to 0.6.1
          - upgraded object-storage plugins to 2.3.0
23.9.2 :  - upgraded Orthanc Explorer 2 plugin to 1.1.3
23.9.1 :  - upgraded Orthanc Explorer 2 plugin to 1.1.2
23.9.0 :  - upgraded advanced authorization plugin to 0.6.0
          - upgraded Orthanc Explorer 2 plugin to 1.1.1
23.8.2 :  - upgraded Python plugin to 4.1
23.8.1 :  - upgraded DICOMweb plugin to 1.15
          - upgraded base image to debian:bullseye-20230814-slim
23.8.0 :  - upgraded Orthanc Explorer 2 plugin to 1.1.0
          - upgraded object-storage plugins to 2.2.0
23.7.1 :  - upgraded base image to debian:bullseye-20230703-slim
          - upgraded WSI framework to 2.0
          - upgraded Orthanc Explorer 2 plugin to 1.0.3
23.7.0 :  - upgraded Orthanc to 1.12.1
          - upgraded DICOMweb plugin to 1.14
          - upgraded PostgreSQL plugins to 5.1
          - upgraded MySQL plugins to 5.1
          - upgraded StoneWebViewer to 2.5+4087511e8eef (Docker images only)
          - upgraded Orthanc Explorer 2 plugin to 1.0.2
          - Added a new special env var: ORTHANC__OHIF to define the "OHIF" configuration in one go.
            Also added 4 non standard env vars for OHIF configuration ORTHANC__OHIF__DATA_SOURCE,
            ORTHANC__OHIF__USER_CONFIGURATION, ORTHANC__OHIF__ROUTER_BASE_NAME, ORTHANC__OHIF__PRELOAD
23.6.1 :  - added OHIF plugin 1.0
          - upgraded Orthanc Explorer 2 plugin to 1.0.1
          - upgraded advanced authorization plugin to 0.5.3
          - During startup, now performing standard env var substitution when reading the 
            configuration files.
23.6.0 :  - POSSIBLE BREAKING CHANGE:
            Created an 'orthanc' user (uid = 999) and 'orthanc' group (gid = 999) inside the image
            to allow executing the image as a non root user.  The image is still executing as root
            by default but some files/folders ownership have been changed to 'orthanc:orthanc' (they 
            should still be accessible to the root user).  Be extra carefull if you have derived 
            from this image and/or if you were already running as non root.
          - upgraded base image to debian:bullseye-20230522-slim
23.5.1 :  - upgraded Kitware's VolView plugin to 1.1 (which corresponds to VolView 4.1)
23.5.0 :  - upgraded advanced authorization plugin to 0.5.2
          - upgraded Orthanc Explorer 2 plugin to 0.9.3
23.4.0 :  - upgraded Orthanc to 1.12.0
          - upgraded advanced authorization plugin to 0.5.1
          - upgraded PostgreSQL plugins to 5.0
          - upgraded MySQL plugins to 5.0
          - upgraded Orthanc Explorer 2 plugin to 0.9.2
23.3.5 :  - WIN-INSTALLER: added the Python plugins
          - WIN-INSTALLER: replaced the "full" installation by a "standard" installation in
            which the Python plugins are not included by default.
          - upgraded base image to debian:bullseye-20230320-slim
23.3.4 :  - upgraded Orthanc Explorer 2 plugin to 0.8.2
          - added Kitware's VolView plugin 1.0
23.3.3 :  - upgraded Orthanc Explorer 2 plugin to 0.8.1
23.3.2 :  - upgraded Orthanc Explorer 2 plugin to 0.8.0
23.3.0 :  - upgraded base image to debian:bullseye-20230227-slim
          - upgraded advanced authorization plugin to 0.5.0
          - upgraded Orthanc Explorer 2 plugin to 0.7.0
23.2.0 :  - upgraded Orthanc to 1.11.3
          - upgraded Orthanc Explorer 2 plugin to 0.6.0
          - upgraded DICOMweb plugin to 1.13
          - upgraded transfers accelerator plugin 1.4
          - upgraded base image to debian:bullseye-20230202-slim
22.12.2:  - upgraded base image to debian:bullseye-20221205-slim
          - upgraded object-storage plugins to 2.1.2
          - upgraded Orthanc Explorer 2 plugin to 0.5.1
          - 2 new special env vars: ORTHANC__POSTGRESQL and ORTHANC__MYSQL to define the "PostgreSQL"
            and "MySQL" whole configuration nodes in one go
          - WIN-INSTALLER: added the Azure storage plugin (64bits only)
22.12.1:  - not released
22.12.0:  - upgraded Stone Web viewer to 2.5
22.11.4:  - upgraded transfers accelerator plugin 1.3
22.11.3:  - upgraded advanced authorization plugin to 0.4.1
22.11.2:  - upgraded advanced authorization plugin to 0.4.0
22.11.1:  - upgraded base image to debian:bullseye-20221024-slim
          - upgraded Orthanc Explorer 2 plugin to 0.4.3
          - fixed Stone Web Viewer frontend version
22.11.0:  - upgraded Stone Web viewer to 2.4
22.10.4:  - upgraded Orthanc Explorer 2 plugin to 0.4.2
22.10.3:  - upgraded DICOMweb plugin to 1.12
22.10.2:  - upgraded object-storage plugins to 2.1.0
22.10.1:  - upgraded DICOMweb plugin to 1.11
22.10.0:  - forget it !
22.9.2 :  - upgraded advanced authorization plugin to 0.3.0
22.9.1 :  - 2 new environment variables to force the hostid or disable generation of a random one if it is missing.
            DCMTK calls gethostid() when generating DICOM UIDs (used, e.g, in modifications/anonymizations).
            When /etc/hostid is missing, the system tries to generate it from the IP of the system.
            On some system, in particular circumstances, we have observed that the system performs a DNS query
            to get the IP of the system.  This DNS can timeout (after multiple with retries) and, in particular cases,
            we have observed a delay of 40 seconds to generate a single DICOM UID in Orthanc.
            Therefore, if /etc/hostid is missing, we now generate it with a random number (default behaviour).  
            This behaviour can still be deactivated by defining GENERATE_HOST_ID_IF_MISSING=false.  
            The host id can also be forced by defining FORCE_HOST_ID.
22.9.0 :  - upgraded Orthanc Explorer 2 plugin to 0.4.1
22.8.0 :  - upgraded Orthanc to 1.11.2
          - upgraded Orthanc Explorer 2 plugin to 0.4.0
          - upgraded DICOMweb plugin to 1.10
          - upgraded object-storage plugins to 2.0.0 (BREAKING CHANGE if using client-side encryption, check the plugin release notes)
          - upgraded base image to debian:bullseye-20220801-slim
          - force latest OpenSSL version (static link instead of dynamic)          
22.7.0 :  - upgraded transfers accelerator plugin 1.2
22.6.4 :  - upgraded Orthanc to 1.11.1
          - upgraded DICOMweb plugin to 1.9
          - added DelayedDeletion plugin (version 1.11.1)
22.6.3 :  - upgraded transfers accelerator plugin 1.1
22.6.2 :  - upgraded Orthanc Explorer 2 plugin to 0.3.3 
22.6.1 :  - from this release, Azure and Google plugins are no more in the default image but are included in the '-full' image.
22.6.0 :  - upgraded Orthanc Explorer 2 plugin to 0.3.2
22.5.4 :  - upgraded Orthanc Explorer 2 plugin to 0.3.0
22.5.3 :  - upgraded Orthanc Explorer 2 plugin to 0.2.2
22.5.2 :  - added Orthanc Explorer 2 plugin (version 0.2.1)
          - upgraded advanced authorization plugin to 0.2.5
22.5.1 :  - upgraded DICOMweb plugin to 1.8
22.5.0 :  - upgraded Orthanc to 1.11.0
          - added Housekeeper plugin (version 1.11.0)
22.4.0 :  - added the neuroimaging plugin
          - upgraded base image to debian:bullseye-20220328-slim
22.3.0 :  - upgraded Stone Web viewer plugin to 2.3
          - updated Orthanc to 1.10.1
          - upgraded GDCM plugin to 1.5
22.2.2 :  - upgraded Python plugin to 4.0
22.2.1 :  - updated Orthanc to 1.10.0
          - updated Orthanc Web viewer to 2.8
22.2.0 :  - upgraded base image to debian:bullseye-20220125-slim
          - added the 3 object storage plugins in the public osimis/orthanc images (version 1.3.3)
          - updated TCIA plugin to 1.1
          - updated WSI framework to 1.1
          - updated ODBC plugin to 1.1
          - removed the "UNLOCK" environment variable that was only used in PostgreSQL < 1.0
21.11.0 : - upgraded base image to debian:bullseye-slim which implies:
            - python upgraded to 3.9
            - lua updated to 5.4
          - upgraded transfers plugin to mainline version (49e9245b4005) to benefit from build process fixes (no new features)
          - now including the WSI dicomizer tools:
            - /usr/local/bin/OrthancWSIDicomizer
            - /usr/local/bin/OrthancWSIDicomToTiff
            - note that libopenslide has been installed too (use /usr/local/bin/OrthancWSIDicomizer --openslide=libopenslide.so.0 /my/file.svs)
          - the MSSQL commercial plugin has been removed from the image.  
            The orthanc-odbc plugin can now be used with MSSQL server.  However, note that the DB schemas are not compatible and therefore, 
            you need to start a new Orthanc from scratch and copy all data from the old Orthanc to the new one 
            (https://book.orthanc-server.com/users/replication.html#generic-replication).
            Also note that as of today, msodbcsql17 is not available on Debian bullseye, therefore, in order to use Orthanc with MSSQL,
            you should use the 21.10.0-buster image.
21.10.0 : - added an aliveness probe script in /probes/test-aliveness.py
21.9.2  : - added the Indexer plugin
          - WIN-INSTALLER: added the Indexer plugin
21.9.1  : - added LOGDIR & LOGFILE environment variables to control the --logdir and --logfile command line options
21.9.0  : - upgraded object-storage plugins to 1.3.3
          - added the TCIA plugin
          - removed the Osimis Cloud plugin
          - INTERNAL: installing a plugin now links it in the target directory if
            possible or copies it otherwise, instead of moving it; this
            allows for "read-only" containers
          - INTERNAL: install plugins in /run/orthanc/plugins if the directory is
            present, usually with the intent to run a "read-only"
            container with tmpfs mounted on /run or subdirectories
          - INTERNAL: load plugins from /run/orthanc/plugins in addition to
            /usr/share/orthanc/plugins; a warning is currently issued if
            the directory doesn't exist and can be ignored
          - INTERNAL: /usr/share/orthanc/plugins-disabled renamed to
            /usr/share/orthanc/plugins-available; a symbolic link is
            left behind for backward-compatibility
          - INTERNAL: compatibility warning: any build processes which may rely on
            "enabled" plugins to be unlinked from the plugins-disabled
            directory need to be updated and assume the semantics of the
            plugins-available directory
          - WIN-INSTALLER: added the TCIA plugin + removed the Osimis Cloud plugin
21.8.3  : - upgraded Orthanc to 1.9.7
          - upgraded Python plugin to 3.4
          - upgraded DICOMweb plugin to 1.7
          - upgraded Stone Web viewer plugin to 2.2
21.8.2  : - now including the WSI dicomizer tools:
            - /usr/local/bin/OrthancWSIDicomizer
            - /usr/local/bin/OrthancWSIDicomToTiff
            - note that libopenslide has been installed too (use /usr/local/bin/OrthancWSIDicomizer --openslide=libopenslide.so.0 /my/file.svs)
          - upgraded DCMTK to 3.6.6 with static build to fix some DICOM TLS issues in Orthanc
21.8.1  : - upgraded Python plugin to 3.3
          - added orthanc-odbc plugins
21.8.0  : - added the BEFORE_ORTHANC_STARTUP_SCRIPT env var to execute a custom script before Orthanc startup
21.7.4  : - upgraded MySQL plugins to 4.3
21.7.3  : - upgraded Orthanc to 1.9.6
          - upgraded MySQL plugins to 4.2
21.7.2  : - upgraded object-storage plugins to 1.3.2
21.7.1  : - upgraded object-storage plugins to 1.3.1
21.7.0  : - upgraded Orthanc to 1.9.5
          - upgraded Stone Web viewer plugin to 2.1
          - upgraded MySQL plugins to 4.1
          - upgraded GDCM plugin to 1.4
21.6.2  : - upgraded object-storage plugins to 1.3.0 (possible BREAKING CHANGE in object-storage plugins, check the plugin release notes)
          - upgraded base image to debian:buster-20210511-slim
          - removed curl tool and wget from the image (libcurl is used by Orthanc and cannot be removed)
          - cleanup unnecessary packages that can trigger errors during security scan and that are not used (build-essential, perl, bzip2, gnupg, xdg-user-dirs)
21.6.1  : - upgraded Orthanc to 1.9.4
          - upgraded GDCM plugin to 1.3
21.6.0  : - upgraded Python plugin to 3.2
          - updated "env-var-non-standards" for new options in MySQL and PostgreSQL plugins
21.5.2  : - upgraded Stone Web viewer plugin to 2.0
21.5.1  : - upgraded Orthanc to 1.9.3
          - upgraded DICOMweb plugin to 1.6
21.5.0  : - fixed missing dependency for AWS object-storage-plugin
21.4.1  : - upgraded object-storage plugins to 1.2.0 
21.4.0  : - upgraded Orthanc to 1.9.2
            Note: if using multiple Orthanc on the same DB, you might want to define ORTHANC__DATABASE_SERVER_IDENTIFIER
          - upgraded PostgreSQL plugins to 4.0
          - upgraded MySQL plugins to 4.0
          - removed vim from Docker images
          - upgraded base image to debian:buster-20210329-slim
21.2.0  : - upgraded Orthanc to 1.9.1
21.1.7  : - upgraded Orthanc to 1.9.0
21.1.6  : - upgraded DICOMweb plugin to 1.5
21.1.5  : - upgraded Python plugin to 3.1
          - WIN-INSTALLER: partial fix of Orthanc issue 48 (uninstaller waits for Orthanc service termination)
21.1.4  : - upgraded WVP_ALPHA to 4a4a657
21.1.3  : - upgraded WSI to 1.0
21.1.2  : - upgraded osimis-cloud plugin to 0.3
21.1.1  : - upgraded WVB to 1.4.2
          - upgraded WVB_ALPHA to 1.4.2
20.12.7 : - linking the Azure blob storage plugin with a new version of cpprestsdk to avoid a leap year bug
20.12.6 : - upgraded Orthanc to 1.8.2
          - upgraded DICOMweb plugin to 1.4
          - upgraded GDCM plugin to 1.2
          - upgraded MySQL plugins to 3.0
          - upgraded PostgreSQL plugins to 3.3
          - upgraded Python plugin to 3.0
          - upgraded Orthanc Web viewer to 2.7
          - upgraded advanced authorization plugin to 0.2.4 (now deprecated)
20.12.5 : - upgraded WVB_ALPHA to e38953e
          - upgraded WVP_ALPHA to 8448639
20.12.4 : - upgraded osimis-cloud plugin to 0.2
20.12.3 : - upgraded Orthanc to 1.8.1
20.12.2 : - set default value for MALLOC_ARENA_MAX=5 (default value was not set before)
20.12.1 : - fixed conflicts between OsimisViewerBasic config and StoneViewer config
20.12.0 : - added the Stone Web viewer 1.0 plugin
20.11.2 : - upgraded WVB to 1.4.1
          - upgraded WVB_ALPHA to 1.4.1
          - upgraded WVP to 1.4.1.0
          - upgraded WVP_ALPHA to 1.4.1.0
20.11.1 : - upgraded DICOMweb to 1.3
20.10.2 : - upgraded Orthanc to 1.8.0
20.10.1 : - now removing EOL of secrets right after reading them
          - object-storage plugins now compiled in Release mode
20.9.6  : - upgraded Orthanc to 1.7.4
          - removed default values for WVP LicenseString since it's not needed anymore
20.9.5  : - upgraded object-storage plugins to 1.1.0
20.9.4  : - upgraded WVB to 1.4.0
          - upgraded WVB_ALPHA to 1.4.0
          - upgraded WVP to 1.4.0.0 - this viewer is not CE marked anymore 
          - upgraded WVP_ALPHA to 1.4.0.0 - this viewer is not CE marked anymore
20.9.3  : - upgraded osimis-cloud plugin to 0.1
20.9.2  : - upgraded object-storage plugins to 1.0.1
20.9.1  : - upgraded object-storage plugins to 1.0.0
          - added the "osimis cloud" plugin (beta version)
          - added environment variable OSIMIS_CLOUD_PLUGIN_ENABLED
20.8.2 :  - added a lua script in "/lua-scripts/filter-http-tools-reset.lua" in order to 
            regenerate the /tmp/orthanc.json configuration file when /tools/reset is called (not loaded by default)
20.8.1 :  - upgraded object-storage plugins to 0.9.3
20.8.0 :  - upgraded Orthanc to 1.7.3
          - upgraded orthanc-gdcm to 1.1
20.7.3 :  - upgraded WVB_ALPHA to 2ebaa948
          - upgraded WVP_ALPHA to f88bb2cf
20.7.2 :  - upgraded WVP_ALPHA to 564f8a8b (info popup)
          - upgraded WVB_ALPHA to d88d2799 (info popup)
          - upgraded object-storage plugins to 0.9.2
20.7.1 :  - upgraded Orthanc to 1.7.2
          - upgraded Python plugin to 2.0
20.7.0 :  - moved GoogleCloudPlatform plugin to the orthanc-pro image (rationale: https://www.osimis.io/en/services.html#cloud-plugins)
          - orthanc-pro: Added Aws S3 plugin 
          - orthanc-pro: Added Azure Blob Storage plugin 
          - orthanc-pro: Added Google Cloud Storage plugin
          - orthanc-pro: Removed previous Azure Storage plugin (v 0.3.2)
          - orthanc-pro: MSSQL plugin "Lock" now defaults to false
          - INTERNAL: docker-entrypoint.sh will not start if not passed a single argument: the path to the configuration file(s)
20.5.3  : - upgraded Orthanc to 1.7.1
          - upgraded Orthanc Web viewer to 2.6
          - upgraded DICOMweb to 1.2
          - upgraded WSI to 0.7
          - upgraded base image to debian:buster-20200514-slim
          - added orthanc-gdcm plugin
20.5.2  : - upgraded Orthanc to 1.7.0
20.5.1  : - updated Lua to 5.3 (was 5.1)
20.5.0  : - tag used only for windows installers; not Docker images
20.4.3  : - fix errors when there's a directory in /run/secrets/
20.4.2  : - Startup completely rewritten in python.  New environment variables for all settings.
            Check the new documentation https://book.orthanc-server.com/users/docker-osimis.html.
            previous env vars are still valid till June 2021
          - added the python plugin (with python3.7 already installed in the image)
          - new base image is now Debian:buster-slim instead of ubuntu:16.04
          - BREAKING CHANGE: backward compatibility of GoogleCloudPlatform plugin environment variables could not be maintained.
            A JSON section must now be provided for each "Accounts"
          - BREAKING CHANGE: the previous xx_BUNDLE_DEFAULTS env vars are now ignored.  That should
            usually not have any impact since defaults are applied only if you've not defined them.
20.4.1  : - upgraded Orthanc to 1.6.1
          - upgraded WVB_ALPHA to ffb6a998
          - upgraded WVP_ALPHA to 68fa1f85
20.4.0  : - upgraded WVB_ALPHA to 35889ad3
          - upgraded WVP_ALPHA to 5eccd29d
20.3.1  : - upgraded Orthanc to 1.6.0
20.3.0  : - upgraded DICOMweb to 1.1
          - Added SCHED_MAX_QUEUED_JOBS and SCHED_MAX_CONCURRENT_JOBS.
          - Deprecated SCHED_MAX_JOBS.
          - add SCHED_JOBS_HISTORY_SIZE
          - BREAKING CHANGE: sub-option "HasWadoRsUniversalTransferSyntax" must be set to "false" 
            in the DW_SERVERS configuration option of the DICOMweb module, if contacting an
            Orthanc server that is equipped with release <= 1.0 of the DICOMweb plugin.
            https://book.orthanc-server.com/plugins/dicomweb.html#client-related-options
          - add LUA_OPTIONS env var
          - add TRANSFERS_BUCKET_SIZE env var
          - add TRANSFERS_CACHE_SIZE env var
          - add TRANSFERS_MAX_PUSH_TRANSACTIONS env var
          - add STORAGE_ACCESS_ON_FIND en var
          - add DICOM_QUERY_RETRIEVE_SIZE env var
          - add DICOM_DICTIONARY env var
20.2.0  : - upgraded MSSQL to 1.1.0, added MSSQL_MAXIMUM_CONNECTION_RETRIES & MSSQL_CONNECTION_RETRY_INTERVAL
20.1.0  : - Introduced gcp-dicom setup procedure
          - upgraded WVB to 1.3.1
          - upgraded WVB_ALPHA to 1.3.1
          - upgraded WVP to 1.3.1.0
          - upgraded WVP_ALPHA to 1.3.1.0
19.11.2 : - added INSTANCE_INFO_CACHE_ENABLED env var for viewer PRO
19.11.1 : - added INSTANCE_INFO_CACHE_ENABLED env var
19.10.4 : - really added HTTP_REQUEST_TIMEOUT (default = 30)
19.10.3 : - added HTTP_REQUEST_TIMEOUT (default = 30)
19.10.2 : - upgraded Orthanc to 1.5.8
          - BREAKING CHANGE: added EXECUTE_LUA_ENABLED settings (default = false).
            This options, when set to false, disables the /tools/execute-script Rest API route.
            If you decide to set EXECUTE_LUA_ENABLED to true, make sure that you know what you're
            doing and that this API route is protected from the outside world or secured by another mean.
            Anyone could execute any code on your machine from this route !
          - BREAKING CHANGE: added AC_AUTHENTICATION_ENABLED setting (default = true).  
            It means that you'll need a login/pwd to access orthanc !  These login/pwd shall be defined 
            in AC_REGISTERED_USERS.  If no login/pwd are defined, Orthanc will generate a default user (orthanc:orthanc)
            and will display a warning in the Orthanc Explorer stating that your setup is insecure.
            If you decide to set AC_AUTHENTICATION_ENABLED to false, make sure that you know what you're
            doing and that your Orthanc is either not accessible from the outside world or secured by another mean.
            Note that if AC_AUTHENTICATION_ENABLED is false, Orthanc Explorer will display a warning stating that your
            setup is insecure.
19.10.1 : - upgraded WVB_ALPHA to 7aff3d60 (PatientBirthDate in overlay + small fixes)
          - upgraded WVP_ALPHA to aa6dbe8f (PatientBirthDate in overlay + small fixes)
19.9.4  : - upgraded WVB to 1.3.0
          - upgraded WVB_ALPHA to 1.3.0
          - upgraded WVP to 1.3.0.0
          - upgraded WVP_ALPHA to 1.3.0.0
19.9.3 :  - added WVB_REFERENCE_LINES_ENABLED, WVB_CROSS_HAIR_ENABLED, WVB_SYNCHRONIZED_BROWSING_ENABLED settings
          - added WVP_REFERENCE_LINES_ENABLED, WVP_CROSS_HAIR_ENABLED, WVP_SYNCHRONIZED_BROWSING_ENABLED settings
19.9.2 :  - upgraded WVP_ALPHA to adf96ee7 (3 new settings in config file - this is also a 1.3.0.0 release candidate)
          - upgraded WVB_ALPHA to b80cd32a (3 new settings in config file - this is also a 1.3.0 release candidate)
19.9.1 :  - added AC_AUTHENTICATION_ENABLED setting (default = false).  Warning, in future releases (featuring Orthanc 1.5.8,
            this setting will be set to true by default)
          - base ubuntu:16.04 image has been updated.  The tzdata package is now installed explicitely.
          - upgraded WVP_ALPHA to 136f6137 (new pickableStudyIds & selectedStudyIds query args)
          - upgraded WVB_ALPHA to 2b16a5e6 (new pickableStudyIds & selectedStudyIds query args)
19.7.1 :  - upgraded WVP_ALPHA to f63878c (uuid in annotations)
          - upgraded WVB_ALPHA to 871b22f4 (uuid in annotations)
19.6.4 :  - upgraded WVP_ALPHA to e3b6a91 (fix query args)
          - upgraded WVB_ALPHA to 4419b1b8 (fix query args)
19.6.3 :  - upgraded WVP_ALPHA to acf5875 (query args passed as HTTP headers to backend + language query arg)
          - upgraded WVB_ALPHA to 4431bea9 (query args passed as HTTP headers to backend + language query arg)
          - added WVB_PRINT_ENABLED & WVP_PRINT_ENABLED settings
          - added WVB_DOWNLOAD_AS_JPEG_ENABLED & WVP_DOWNLOAD_AS_JPEG_ENABLED settings
19.6.2 :  - upgraded Orthanc to 1.5.7
          - upgraded DICOMweb to 1.0
          - added Google Cloud Platform plugin 1.0
19.6.1 :  - upgraded WVB_ALPHA to 45f6d268 (fix Download as jpeg + fix synchronized browsing)
          - upgraded WVP_ALPHA to 03093e6 (fix Download as jpeg + fix synchronized browsing)
19.6.0 :  - upgraded WVB_ALPHA to c9110211 (Download as jpeg)
          - upgraded WVP_ALPHA to 84de39e (Download as jpeg)
19.4.1 :  - upgraded WVP_ALPHA to d4b6c4b
19.3.4 :  - upgraded WVP_ALPHA to cd1ad9a
19.3.3 :  - Add USERMETADATA setting
19.3.2 :  - added transfers accelerator plugin 1.0
19.3.1 :  - upgraded Orthanc to 1.5.6
          - upgraded PostgreSQL plugins to 3.2
          - upgraded Orthanc Web viewer to 2.5
          - upgraded DICOMweb plugin to 0.6
          - upgraded WSI plugin to 0.6
19.2.2 :  - Upgraded Orthanc to 1.5.5
19.2.1 :  - Upgraded Orthanc to 1.5.4
          - Upgraded PostgreSQL to 3.1
          - Add SERIES_TO_IGNORE setting (WVB and WBP)
          - Add NO_JOBS setting to add the --no-jobs option at Orthanc command line
          - Add UNLOCK setting to add the --unlock option at Orthanc command line
19.1.1  : - upgraded Orthanc to 1.5.3
          - upgraded PostgreSQL to 3.0
          - upgraded MySQL to 2.0
          - Add HTTP_KEEP_ALIVE setting
          - Add TCP_NODELAY setting
          - Add SCHED_SAVE_JOBS and SCHED_MAX_JOBS settings
18.12.3 : - upgraded Orthanc to 1.5.1
18.12.2 : - upgraded WVB_ALPHA to 7c4d1a44 (Cross-Hair)
          - upgraded WVP_ALPHA to 6b11ef5 (Cross-Hair)
18.12.1 : - upgraded blob storage plugin to 0.3.2 (previous version was not compatible with ubuntu 16.04)
18.12.0 : - upgraded Orthanc to 1.5.0
          - upgraded WVP_ALPHA to 68ad0db
18.11.1 : - upgraded WVB to 1.2.0
          - upgraded WVB_ALPHA to 1.2.0
          - upgraded WVP to 1.2.0.0
          - upgraded WVP_ALPHA to 1.2.0.0
18.11.0 : - DICOM_SYNCHRONOUS_CMOVE now set to "true" by default
18.9.5  : - Fix double prefix issue for DICOM_ALWAYS_ALLOW_ECHO_ENABLED and DICOM_ALWAYS_ALLOW_STORE_ENABLED
          - Add DICOM_SYNCHRONOUS_CMOVE setting
18.9.4  : - Add IMPORT_OVERWRITE_INSTANCES setting
18.9.3  : - upgraded Orthanc to 1.4.2
18.9.2  : - upgraded WVB_ALPHA to 090cd828 (improved synchronization)
18.9.1  : - upgraded WVP_ALPHA to 7090062 (fix copy-paste in Live-Share)
          - Bug fix: in 18.8.1: WVP and WVP_ALPHA were inverted
18.8.1  : - upgraded Authorization plugin to 0.2.2
          - Add WVB_OPEN_ALL_PATIENT_STUDIES and WVP_OPEN_ALL_PATIENT_STUDIES settings
          - upgraded WVP_ALPHA to 9c6b4d3 (fix for print + JP2K display)
          - internal: the build has been optimized and is now just a matter of assembling
            binaries that have been produced by other build-systems.  Note that we use LSB binaries
            for Orthanc and some of its plugins: OrthancViewer, ModalityWorklist, DICOMweb,
            PostgreSQL, MySQL, WSI.
18.7.3  : - added env var DICOM_UNKNOWN_SOP_CLASS_ACCEPTED
18.7.2  : - Introduced WVB_ALPHA_ENABLED to use alpha version of the Osimis WebViewer plugin
          - upgraded MySQL to 1.1
          - upgraded WVP_ALPHA to 73e6b64
          - upgraded WVB_ALPHA to c3ac8fac
18.7.1  : - upgraded Orthanc to 1.4.1
          - upgraded PostgreSQL to 2.2
          - added MySQL 1.0
18.7.0  : - upgraded Orthanc to 1.4.0
18.6.0  : - Deprecated LISTENER_LISTEN_ALL_ADDR
          - Introduced access-control setup procedure
18.5.2  : - upgraded WVP_ALPHA to 1.1.1.0
          - upgraded WVP to 1.1.1.0
          - upgraded WVB to 1.1.1
18.5.1  : - added env vars WV{B,P}_COMBINED_TOOL_ENABLED, DEFAULT_SELECTED_TOOL, LANGUAGE, TOGGLE_OVERLAY_TEXT_BUTTON_ENABLED
18.5.0  : - upgraded WVP_ALPHA to 1.1.0.0
          - upgraded WVP to 1.1.0.0
          - upgraded WVB to 1.1.0
18.4.4  : - upgraded DICOMweb to 0.5
          - upgraded PostgreSQL to 2.1
          - upgraded Orthanc Web viewer to 2.4
          - upgraded WSI to 0.5
18.4.3  : - upgraded Orthanc to 1.3.2
          - upgraded MSSQL to 1.0.0
18.4.2  : - added TRACE_ENABLED env var
18.4.1  : - upgraded WVP_ALPHA to 2cfa333 (fix shortcuts in Liveshare + fix default windowing in some RGB images) 
18.4.0  : - added env vars for authorization plugin
18.3.5  : - added WV{B,P}_KEYBOARD_SHORTCUTS_ENABLED
18.3.4  : - upgraded WVP_ALPHA to 55390bf (fix Liveshare + some opti)
18.3.3  : - forget it !
18.3.2  : - downgraded MSSQL back to 0.5.0 (0.6.1 is not compatible with Orthanc 1.3.1)
18.3.1  : - upgraded Authorization plugin to 0.2.1 + MSSQL to 0.6.1 + WVP_ALPHA to ae8b463
18.3.0  : - upgraded Authorization plugin to 0.2.0 + WVP_ALPHA to 2c43e74 (shortcuts + combined tool + synchronized browsing)
18.1.6  : - upgraded WVB to 1.0.2 and WVP to 1.0.2.0 (Annotation storage hot-fix)
18.1.5  : - added DW_STOW_MAX_INSTANCES & DW_STOW_MAX_SIZE
          - upgraded WVP_ALPHA to df1592b (previous build was not available) 
18.1.4  : - upgraded WVP_ALPHA to 335ab7a (for correct support of KeyImageCaptureEnabled)
18.1.3  : - added WVB_KEY_IMAGE_CAPTURE_ENABLED
18.1.2  : - added WVP_KEY_IMAGE_CAPTURE_ENABLED
18.1.1  : - upgraded WVP_ALPHA to 13ce4ba (to fix the windowingPresets in Lify)
17.12.2 : - include ca-certificates in image and use them by default for Orthanc HttpClient
```
