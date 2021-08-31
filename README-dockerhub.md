# Orthanc for Docker
Docker image with [Orthanc](http://www.orthanc-server.com/) and its official plugins. Orthanc is a lightweight, RESTful Vendor Neutral Archive for medical imaging.

Note: the Orthanc version included in this image is exactly the same as the Orthanc included in the `jodogne/orthanc` image.  However,
this image contain the Osimis Web Viewer plugin which is not included in the `jodogne/orthanc-plugins` image.  Furthermore,
this image provides an easy configuration through environment variables which is not the case of the `jodogne/orthanc` image.

Full documentation is available [here](https://book.orthanc-server.com/users/docker-osimis.html).

Sample setups using this image are available [here](https://bitbucket.org/osimis/orthanc-setup-samples/).

Release notes are available [here](https://bitbucket.org/osimis/orthanc-builder/src/master/release-notes-docker-images.txt)


# packages content

#### 21.8.2
```

component                             version
---------------------------------------------
Orthanc server                        1.9.7
Stone Web viwer plugin                2.1
Osimis Web viewer plugin              1.4.2
Osimis Web viewer plugin (alpha)      1.4.2
Modality worklists plugin             1.9.7
Serve folders plugin                  1.9.7
Connectivity check plugin             1.9.7
Python plugin                         3.4
Orthanc Web viewer plugin             2.7
DICOMweb plugin                       1.7
PostgreSQL plugin                     4.0
MySQL plugin                          4.3
WSI Web viewer plugin                 1.0
Authorization plugin                  0.2.4
Transfers accelerator plugin          1.0
GDCM plugin                           1.4
Osimis cloud synchronization plugin   0.3
ODBC plugin                           1.0
```
