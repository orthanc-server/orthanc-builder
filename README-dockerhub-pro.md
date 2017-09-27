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
Osimis Web viewer pro plugin (alpha)  prerelease-1.1.0.0
```


# Settings

#### PostgreSQL Plugin

Environment variables:

- `PG_ENABLED` (default: "false"): To enable the PostgreSQL plugin
- `PG_INDEX_ENABLED`(default: "true"): To enable the index plugin
- `PG_STORAGE_ENABLED`(default: "false"): To enable the storage plugin

Docker secrets:

- `PG_PASSWORD_SECRET`: The password of the PostgreSQL DB

Configuration file:

- `postgresql.json`

#### Osimis Web Viewer Pro Plugin

Docker secrets:

- `WVP_LICENSE_STRING_SECRET`: Osimis-provided license string

Environment variables:

- `WVP_ENABLED` (default: "false"): To enable the WebViewer Pro plugin
- `WVP_STUDY_DOWNLOAD_ENABLED` (default: "true"): Add button to download studies
- `WVP_VIDEO_ENABLED` (default: "true"): Enable video player
- `WVP_ANNOTATIONS_STORAGE_ENABLED` (default: "false"): Persist annotations in Orthanc attachments
- `WVP_LIVESHARE_ENABLED` (default: "false"): Use live collaboration features
- `WVP_LICENSE_STRING` (default: ""): The WVP license string

#### Osimis Web Viewer Pro Plugin (alpha version)

Docker secrets:

- `WVP_ALPHA_LICENSE_STRING_SECRET`: Osimis-provided license string

Environment variables:

- `WVP_ALPHA_ENABLED` (default: "false"): To enable the WebViewer Pro plugin (alpha version)
- `WVP_ALPHA_STUDY_DOWNLOAD_ENABLED` (default: "true"): Add button to download studies
- `WVP_ALPHA_VIDEO_ENABLED` (default: "true"): Enable video player
- `WVP_ALPHA_ANNOTATIONS_STORAGE_ENABLED` (default: "false"): Persist annotations in Orthanc attachments
- `WVP_ALPHA_LIVESHARE_ENABLED` (default: "false"): Use live collaboration features
- `WVP_ALPHA_LICENSE_STRING` (default: ""): The WVP license string

#### MSSQL Plugin

Docker secrets:

- `MSSQL_CONNECTION_STRING_SECRET`: SQL Server connection string
- `MSSQL_LICENSE_STRING_SECRET`: Osimis-provided license string

Environment variables:
- 'MSSQL_ENABLED' (default: "false"): To enable the MSSQL plugin
- `MSSQL_CONNECTION_STRING`: SQL Server connection string
- `MSSQL_LICENSE_STRING`: Osimis-provided license string


#### Azure Storage Plugin

Docker secrets:

- `AZSTOR_ACC_KEY_SECRET`: The account key
- `AZSTOR_LICENSE_STRING_SECRET`: Osimis-provided license string

Environment variables:

- 'AZSTOR_ENABLED' (default: "false"): To enable the Azure Storage plugin
- `AZSTOR_ACC_KEY`: The Azure Storage account key
- `AZSTOR_ACC_NAME`: The Azure Storage account name
- `AZSTOR_CONTAINER`: The Azure Storage Blob service container name
- `AZSTOR_LICENSE_STRING`: Osimis-provided license string

