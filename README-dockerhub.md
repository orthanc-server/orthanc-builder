# Orthanc for Docker
Docker image with [Orthanc](http://www.orthanc-server.com/) and its official plugins. Orthanc is a lightweight, RESTful Vendor Neutral Archive for medical imaging.

Note: the Orthanc version included in this image is exactly the same as the Orthanc included in the `jodogne/orthanc` image.  However,
this image contain the Osimis Web Viewer plugin which is not included in the `jodogne/orthanc-plugins` image.  Furthermore,
this image provides an easy configuration through environment variables which is not the case of the `jodogne/orthanc` image.

Full documentation is available [here](https://book.orthanc-server.com/users/docker-osimis.html).

Sample setups using this image are available [here](https://bitbucket.org/osimis/orthanc-setup-samples/).

Release notes are available [here](https://bitbucket.org/osimis/orthanc-builder/src/master/release-notes-docker-images.txt)


# packages content

#### 20.12.4
```

component                             version
---------------------------------------------
Orthanc server                        1.8.1
Stone Web viwer plugin                1.0
Osimis Web viewer plugin              1.4.1
Osimis Web viewer plugin (alpha)      e38953e
Modality worklists plugin             1.8.1
Serve folders plugin                  1.8.1
Connectivity check plugin             1.8.1
Python plugin                         2.0
Orthanc Web viewer plugin             2.6
DICOMweb plugin                       1.3
PostgreSQL plugin                     3.2
MySQL plugin                          2.0
WSI Web viewer plugin                 0.7
Authorization plugin                  0.2.3
Transfers accelerator plugin          1.0
GDCM plugin                           1.1
Osimis cloud synchronization plugin   0.1
```
