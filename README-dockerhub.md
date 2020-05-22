# Orthanc for Docker
Docker image with [Orthanc](http://www.orthanc-server.com/) and its official plugins. Orthanc is a lightweight, RESTful Vendor Neutral Archive for medical imaging.

Note: the Orthanc version included in this image is exactly the same as the Orthanc included in the `jodogne/orthanc` image.  However,
this image contain the Osimis Web Viewer plugin which is not included in the `jodogne/orthanc-plugins` image.  Furthermore,
this image provides an easy configuration through environment variables which is not the case of the `jodogne/orthanc` image.

Full documentation is available [here](https://book.orthanc-server.com/users/docker-osimis.html).

Sample setups using this image are available [here](https://bitbucket.org/osimis/orthanc-setup-samples/).

Release notes are available [here](https://bitbucket.org/osimis/orthanc-builder/src/master/release-notes-docker-images.txt)


# packages content

#### 20.5.2
```

component                             version
---------------------------------------------
Orthanc server                        1.7.0
Osimis Web viewer plugin              1.3.1
Osimis Web viewer plugin (alpha)      ffb6a998
Modality worklists plugin             1.7.0
Serve folders plugin                  1.7.0
Connectivity check plugin             1.7.0
Orthanc Web viewer plugin             2.5
DICOMweb plugin                       1.1
PostgreSQL plugin                     3.2
MySQL plugin                          2.0
WSI Web viewer plugin                 0.6
Authorization plugin                  0.2.3
Transfers accelerator plugin          1.0
Google Cloud Platform plugin          1.0
```
