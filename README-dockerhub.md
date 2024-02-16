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

Release notes are available [here](https://github.com/orthanc-server/orthanc-builder/blob/master/release-notes-docker-images.txt)


# packages content

#### 24.2.3 Default image
```
component                             version
---------------------------------------------
Orthanc server                        1.12.3
Modality worklists plugin             1.12.3
Serve folders plugin                  1.12.3
Connectivity check plugin             1.12.3
Housekeeper plugin                    1.12.3
Delayed Deletion plugin               1.12.3
Multitenant DICOM plugin              1.12.3
Stone Web viewer plugin               2.5+c23eef785569
Osimis Web viewer plugin              1.4.3
Python plugin                         4.1
Orthanc Web viewer plugin             2.8
DICOMweb plugin                       1.16
PostgreSQL plugins                    6.1
MySQL plugins                         5.1
WSI Web viewer plugin                 2.0
Authorization plugin                  0.7.0
Transfers accelerator plugin          1.4
GDCM plugin                           1.6
ODBC plugin                           1.1
TCIA plugin                           1.1
Orthanc Indexer plugin                1.0
Orthanc neuroimaging plugin           1.0
AWS S3 plugin                         2.3.1
Orthanc Explorer 2                    1.2.2
Kitware's VolView plugin              1.1
OHIF plugin                           1.2
```

#### 24.2.3-full image 
```
additional component                  version
---------------------------------------------
Azure Blob Storage plugin             2.3.1
Google Cloud Storage plugin           2.3.1
````
