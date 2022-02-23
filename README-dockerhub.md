# Orthanc for Docker
Docker image with [Orthanc](https://www.orthanc-server.com/) and its official plugins. Orthanc is a lightweight, RESTful Vendor Neutral Archive for medical imaging.

Note: the Orthanc version included in this image is exactly the same as the Orthanc included in the `jodogne/orthanc` image.  However,
this image contain the Osimis Web Viewer plugin which is not included in the `jodogne/orthanc-plugins` image.  Furthermore,
this image provides an easy configuration through environment variables which is not the case of the `jodogne/orthanc` image.

Full documentation is available [here](https://book.orthanc-server.com/users/docker-osimis.html).

Sample setups using this image are available [here](https://bitbucket.org/osimis/orthanc-setup-samples/).

Release notes are available [here](https://bitbucket.org/osimis/orthanc-builder/src/master/release-notes-docker-images.txt)


# packages content

#### 22.2.1
```

component                             version
---------------------------------------------
Orthanc server                        1.10.0
Stone Web viewer plugin               2.2
Osimis Web viewer plugin              1.4.2
Osimis Web viewer plugin (alpha)      1.4.2
Modality worklists plugin             1.10.0
Serve folders plugin                  1.10.0
Connectivity check plugin             1.10.0
Python plugin                         3.4
Orthanc Web viewer plugin             2.8
DICOMweb plugin                       1.7
PostgreSQL plugin                     4.0
MySQL plugin                          4.3
WSI Web viewer plugin                 1.1
Authorization plugin                  0.2.4
Transfers accelerator plugin          1.0
GDCM plugin                           1.4
ODBC plugin                           1.1
TCIA plugin                           1.1
Orthanc Indexer plugin                1.0
AWS S3 plugin                         1.3.3
Azure Blob Storage plugin             1.3.3
Google Cloud Storage plugin           1.3.3
```
