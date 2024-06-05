# Orthanc for Docker
Docker image with [Orthanc](https://www.orthanc-server.com/) and its official plugins. Orthanc is a lightweight, RESTful Vendor Neutral Archive for medical imaging.

Note: the Orthanc version included in this image is exactly the same as the Orthanc included in the `jodogne/orthanc` image.  However,
this image contains a few plugins that are not included in the `jodogne/orthanc-plugins` image.  Furthermore,
this image provides an easy configuration through environment variables which is not the case of the `jodogne/orthanc` image.

Starting from the `22.6.1` release, we are providing 2 types of images:
  - the default image with the usual tag: e.g `22.6.1`
  - the full image with a e.g `22.6.1-full` tag

The default image is suitable for 99.9% of users.
You should use the full image only if you need to use one of these:
  - the Azure Blob storage plugin
  - the Google Cloud storage plugin
  - the ODBC plugin with SQL Server (msodbcsql18 is preinstalled)

Full documentation is available [here](https://book.orthanc-server.com/users/docker-orthancteam.html).

Sample setups using this image are available [here](https://github.com/orthanc-server/orthanc-setup-samples/).

Release notes are available [here](https://github.com/orthanc-server/orthanc-builder/blob/master/release-notes-docker-images.md)


# packages content

#### 24.6.0 Default image
```
component                             version
---------------------------------------------
Orthanc server                        1.12.4
Modality worklists plugin             1.12.4
Serve folders plugin                  1.12.4
Connectivity check plugin             1.12.4
Housekeeper plugin                    1.12.4
Delayed Deletion plugin               1.12.4
Multitenant DICOM plugin              1.12.4
Stone Web viewer plugin               2.5+c23eef785569
Osimis Web viewer plugin              1.4.3
Python plugin                         4.2
Orthanc Web viewer plugin             2.9
DICOMweb plugin                       1.16
PostgreSQL plugins                    6.2
MySQL plugins                         5.1
WSI Web viewer plugin                 2.0
Authorization plugin                  0.7.2
Transfers accelerator plugin          1.5
GDCM plugin                           1.7
ODBC plugin                           1.2
TCIA plugin                           1.2
Orthanc Indexer plugin                1.1
Orthanc neuroimaging plugin           1.1
AWS S3 plugin                         2.3.1
Orthanc Explorer 2                    1.4.1
Kitware's VolView plugin              1.1
OHIF plugin                           1.2
STL plugin                            1.1


System component                      version
---------------------------------------------
Base image Debian version             12 (bookworm)
Python                                3.11
Lua                                   5.4

```

#### 24.4.0-full image 
```
additional component                  version
---------------------------------------------
Azure Blob Storage plugin             2.3.1
Google Cloud Storage plugin           2.3.1
````
