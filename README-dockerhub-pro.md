# Orthanc for Docker
Docker image with [Orthanc](https://www.orthanc-server.com/) and its official plugins (including commercial plugins). Orthanc is a lightweight, RESTful Vendor Neutral Archive for medical imaging.

Note: the Orthanc version included in this image is exactly the same as the Orthanc version included in the `osimis/orthanc` and `jodogne/orthanc` images.  
This image contains the Osimis commercial plugins requiring a license.  If you don't need a commercial plugin, you should use the `osimis/orthanc` image.

Full documentation is available [here](https://osimis.atlassian.net/wiki/spaces/OKB/pages/26738689/How+to+use+osimis+orthanc+Docker+images).

Sample setups using this image are available [here](https://bitbucket.org/osimis/orthanc-setup-samples/).

Release notes are available [here](https://bitbucket.org/osimis/orthanc-builder/src/master/release-notes-docker-images.txt)


# packages content

#### 20.4.1
```

component                             version
---------------------------------------------
Orthanc server                        1.6.1
Osimis Web viewer plugin              1.3.1
Osimis Web viewer plugin (alpha)      5eccd29d
Modality worklists plugin             1.6.1
Serve folders plugin                  1.6.1
Orthanc Web viewer plugin             2.5
DICOMweb plugin                       1.1
PostgreSQL plugin                     3.2
MySQL plugin                          2.0
WSI Web viewer plugin                 0.6
Authorization plugin                  0.2.2
Transfers accelerator plugin          1.0
Google Cloud Platform plugin          1.0

commercial plugins (requiring a license):

MSSql plugin                          1.1.0
Azure Storage plugin (using blobs)    0.3.2
Osimis Web viewer pro plugin          1.3.1.0
Osimis Web viewer pro plugin (alpha)  1.3.1.0
```
