# Orthanc for Docker
Docker image with [Orthanc](http://www.orthanc-server.com/) and its official plugins. Orthanc is a lightweight, RESTful Vendor Neutral Archive for medical imaging.

Note: the Orthanc version included in this image is exactly the same as the Orthanc included in the `jodogne/orthanc` image.  However,
this image contain the Osimis Web Viewer plugin which is not included in the `jodogne/orthanc-plugins` image.  Furthermore,
this image provides an easy configuration through environment variables which is not the case of the `jodogne/orthanc` image.

Full documentation is available [here](https://book.orthanc-server.com/users/docker-osimis.html).

Sample setups using this image are available [here](https://bitbucket.org/osimis/orthanc-setup-samples/).

Release notes are available [here](https://bitbucket.org/osimis/orthanc-builder/src/master/release-notes-docker-images.txt)


# packages content

#### 21.2.0
```

component                             version
---------------------------------------------
Orthanc server                        1.9.1
Stone Web viwer plugin                1.0
Osimis Web viewer plugin              1.4.2
Osimis Web viewer plugin (alpha)      1.4.2
Modality worklists plugin             1.9.1
Serve folders plugin                  1.9.1
Connectivity check plugin             1.9.1
Python plugin                         3.1
Orthanc Web viewer plugin             2.7
DICOMweb plugin                       1.5
PostgreSQL plugin                     3.3
MySQL plugin                          3.0
WSI Web viewer plugin                 1.0
Authorization plugin                  0.2.4
Transfers accelerator plugin          1.0
GDCM plugin                           1.2
Osimis cloud synchronization plugin   0.3
```
