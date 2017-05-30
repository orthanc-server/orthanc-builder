# Orthanc for Docker
Docker image with [Orthanc](http://www.orthanc-server.com/) and its official plugins. Orthanc is a lightweight, RESTful Vendor Neutral Archive for medical imaging.

Full documentation is available in the [Orthanc Book](http://book.orthanc-server.com/users/docker.html).

Sample procedure (docker-compose file) to use this image is available [here](https://bitbucket.org/snippets/osimis/eynLn/running-orthanc-with-docker)

# Content of packages

## 17.5.1

Changes:

- Same components versions as 17.5
- storage.json now contains a definition for IndexDirectory set to '/var/lib/orthanc/db'


## 17.5

```

component                             version
---------------------------------------------
Orthanc server                        1.2.0
Osimis Web viewer plugin              0.8.0
Modality worklists plugin             1.2.0
Serve folders plugin                  1.2.0
Orthanc Web viewer plugin             2.2
DICOMweb plugin                       0.3
PostgreSQL plugin                     2.0
WSI Web viewer plugin                 0.4
Authorization plugin                  0.1.0

```