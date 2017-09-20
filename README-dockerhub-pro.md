# Orthanc for Docker
Docker image with [Orthanc](http://www.orthanc-server.com/) and its official plugins (including commercial plugins). Orthanc is a lightweight, RESTful Vendor Neutral Archive for medical imaging.

Full documentation is available in the [Orthanc Book](http://book.orthanc-server.com/users/docker.html).

Sample setups using this image are available [here](https://bitbucket.org/osimis/orthanc-setup-samples/).

# packages content

#### 17.9.4
```

component                             version
---------------------------------------------
Orthanc server                        1.3.0
Osimis Web viewer plugin              1.0.0
Modality worklists plugin             1.3.0
Serve folders plugin                  1.3.0
Orthanc Web viewer plugin             2.3
DICOMweb plugin                       0.4
PostgreSQL plugin                     2.0
WSI Web viewer plugin                 0.4
Authorization plugin                  0.1.0

MSSql plugin                          0.5.0
Azure Storage plugin (using blobs)    0.3.0
Osimis Web viewer pro plugin          1.0.0.99 *
```

#### 17.8.0
```

component                             version
---------------------------------------------
Orthanc server                        1.3.0
Osimis Web viewer plugin              1.0.0
Modality worklists plugin             1.3.0
Serve folders plugin                  1.3.0
Orthanc Web viewer plugin             2.3
DICOMweb plugin                       0.4
PostgreSQL plugin                     2.0
WSI Web viewer plugin                 0.4
Authorization plugin                  0.1.0

MSSql plugin                          0.5.0
Azure Storage plugin (using blobs)    0.3.0
Osimis Web viewer pro plugin          bd0f243
```

#### 17.7.1
```

component                             version
---------------------------------------------
Orthanc server                        1.3.0
Osimis Web viewer plugin              1.0.0
Modality worklists plugin             1.3.0
Serve folders plugin                  1.3.0
Orthanc Web viewer plugin             2.3
DICOMweb plugin                       0.4
PostgreSQL plugin                     2.0
WSI Web viewer plugin                 0.4
Authorization plugin                  0.1.0

MSSql plugin                          0.4.1
Osimis Web viewer pro plugin          bd0f243 *
```

#### 17.7.0
```

component                             version
---------------------------------------------
Orthanc server                        1.3.0 *
Osimis Web viewer plugin              1.0.0 *
Modality worklists plugin             1.3.0 *
Serve folders plugin                  1.3.0 *
Orthanc Web viewer plugin             2.3   *
DICOMweb plugin                       0.4   *
PostgreSQL plugin                     2.0
WSI Web viewer plugin                 0.4
Authorization plugin                  0.1.0

MSSql plugin                          0.4.1
Osimis Web viewer pro plugin          bd0f243 *
```

#### 17.6.1
```

component                             version
---------------------------------------------
Orthanc server                        1.2.0
Osimis Web viewer plugin              0.9.1 *
Modality worklists plugin             1.2.0
Serve folders plugin                  1.2.0
Orthanc Web viewer plugin             2.2
DICOMweb plugin                       0.3
PostgreSQL plugin                     2.0
WSI Web viewer plugin                 0.4
Authorization plugin                  0.1.0

MSSql plugin                          0.4.1
Osimis Web viewer pro plugin          f017049 *

```


#### 17.5
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

MSSql plugin                          0.4.1
Osimis Web viewer pro plugin          preview

```

# Settings

#### Osimis Web Viewer Pro Plugin

Docker secrets:

- `wvp-licensestring`: Osimis-provided license string

Environment variables:

- `WVP_STUDY_DOWNLOAD` (default: "true"): Add button to download studies
- `WVP_VIDEO` (default: "true"): Enable video player
- `WVP_ANNOTATIONS_STORAGE` (default: "false"): Persist annotations in Orthanc attachments
- `WVP_LIVESHARE` (default: "false"): Use live collaboration features

#### MSSQL Plugin

Docker secrets:

- `mssql-connectionstring`: SQL Server connection string
- `mssql-licensestring`: Osimis-provided license string

#### Azure Storage Plugin

Docker secrets:

- `azstor-accname`: Azure Storage account name
- `azstor-acckey`: Azure Storage account key
- `azstor-licensestring`: Osimis-provided license string

Environment variables:

- `AZSTOR_CONTAINER` (default: "orthanc"): Azure Storage Blob service container name
