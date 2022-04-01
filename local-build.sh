set -o errexit
set -o xtrace

# example
# ./local-build.sh
# ./local-build.sh stable linux/amd64 1

version=${1:-stable}
platform=${2:-linux/amd64}
skipCommitChecks=${3:-0}      # when building locally, you might set this value to 1 to avoid translating branch into commit_id (faster)
isCiBuild=${4:-0}             # when building on CI
branchTagName=${5:-unknown}   # when building on CI
push=${6:-0}                  # when building on CI

if [[ $push == "0" ]]; then  # either we push or we build !

    # get version number from build-matrix.json (stable or unstable)
    # note: we get the last commit id from a branch to detect last changes in a branch

    getCommitId() { # $1 = name, $2 = version (stable or unstable)
        revision=$(cat build-matrix.json | jq -r ".configs[] | select( .name == \"$1\").$2")

        if [[ $skipCommitChecks == "1" ]]; then
            echo $revision
        else
            repo=$(cat build-matrix.json | jq -r ".configs[] | select( .name == \"$1\").repo")
            commit_id=$(hg identify $repo -r $revision)
            echo $commit_id
        fi
    }

    ORTHANC_COMMIT_ID=$(getCommitId "Orthanc" $version)
    ORTHANC_GDCM_COMMIT_ID=$(getCommitId "Orthanc-gdcm" $version)
    ORTHANC_PG_COMMIT_ID=$(getCommitId "Orthanc-postgresql" $version)
    ORTHANC_MYSQL_COMMIT_ID=$(getCommitId "Orthanc-mysql" $version)
    ORTHANC_TRANSFERS_COMMIT_ID=$(getCommitId "Orthanc-transfers" $version)
    ORTHANC_DW_COMMIT_ID=$(getCommitId "Orthanc-dicomweb" $version)
    ORTHANC_WSI_COMMIT_ID=$(getCommitId "Orthanc-wsi" $version)
    ORTHANC_OWV_COMMIT_ID=$(getCommitId "Orthanc-webviewer" $version)
    ORTHANC_AUTH_COMMIT_ID=$(getCommitId "Orthanc-auth" $version)
    ORTHANC_PYTHON_COMMIT_ID=$(getCommitId "Orthanc-python" $version)
    ORTHANC_ODBC_COMMIT_ID=$(getCommitId "Orthanc-odbc" $version)
    ORTHANC_INDEXER_COMMIT_ID=$(getCommitId "Orthanc-indexer" $version)
    ORTHANC_TCIA_COMMIT_ID=$(getCommitId "Orthanc-tcia" $version)
    ORTHANC_STONE_VIEWER_COMMIT_ID=$(getCommitId "Orthanc-stone" $version)
    ORTHANC_AZURE_STORAGE_COMMIT_ID=$(getCommitId "Orthanc-azure-storage" $version)
    ORTHANC_GOOGLE_STORAGE_COMMIT_ID=$(getCommitId "Orthanc-google-storage" $version)
    ORTHANC_AWS_STORAGE_COMMIT_ID=$(getCommitId "Orthanc-aws-storage" $version)

    if [[ $isCiBuild == "1" ]]; then

        from_cache_arg="--cache-from=osimis/orthanc-builder-base:main-cache-amd64"
        to_cache_arg="--cache-from=osimis/orthanc-builder-base:main-cache-amd64"

        # base images have already been built before in CI
        base_image_tag_arg=
    else
        from_cache_arg=
        to_cache_arg=
        base_image_tag_arg="--build-arg BASE_IMAGE_TAG=current"

        docker build --progress=plain --platform=$platform -t osimis/orthanc-runner-base:current -f docker/orthanc/Dockerfile.runner-base docker/orthanc

        docker build --progress=plain --platform=$platform -t osimis/orthanc-builder-base:current --build-arg BASE_IMAGE_TAG=current -f docker/orthanc/Dockerfile.builder-base docker/orthanc

        docker build --progress=plain --platform=$platform -t osimis/orthanc-builder-base:vcpkg-current --build-arg BASE_IMAGE_TAG=current -f docker/orthanc/Dockerfile.builder-vcpkg --target orthanc-build-vcpkg docker/orthanc
        docker build --progress=plain --platform=$platform -t osimis/orthanc-builder-base:vcpkg-google-current --build-arg BASE_IMAGE_TAG=current -f docker/orthanc/Dockerfile.builder-vcpkg --target orthanc-build-vcpkg-google docker/orthanc
        docker build --progress=plain --platform=$platform -t osimis/orthanc-builder-base:vcpkg-azure-current --build-arg BASE_IMAGE_TAG=current -f docker/orthanc/Dockerfile.builder-vcpkg --target orthanc-build-vcpkg-azure docker/orthanc

    fi

    docker build \
    --progress=plain --platform=$platform -t osimis/orthanc:current \
    --build-arg ORTHANC_COMMIT_ID=$ORTHANC_COMMIT_ID \
    --build-arg ORTHANC_GDCM_COMMIT_ID=$ORTHANC_GDCM_COMMIT_ID \
    --build-arg ORTHANC_PG_COMMIT_ID=$ORTHANC_PG_COMMIT_ID \
    --build-arg ORTHANC_MYSQL_COMMIT_ID=$ORTHANC_MYSQL_COMMIT_ID \
    --build-arg ORTHANC_TRANSFERS_COMMIT_ID=$ORTHANC_TRANSFERS_COMMIT_ID \
    --build-arg ORTHANC_DW_COMMIT_ID=$ORTHANC_DW_COMMIT_ID \
    --build-arg ORTHANC_WSI_COMMIT_ID=$ORTHANC_WSI_COMMIT_ID \
    --build-arg ORTHANC_OWV_COMMIT_ID=$ORTHANC_OWV_COMMIT_ID \
    --build-arg ORTHANC_AUTH_COMMIT_ID=$ORTHANC_AUTH_COMMIT_ID \
    --build-arg ORTHANC_PYTHON_COMMIT_ID=$ORTHANC_PYTHON_COMMIT_ID \
    --build-arg ORTHANC_ODBC_COMMIT_ID=$ORTHANC_ODBC_COMMIT_ID \
    --build-arg ORTHANC_INDEXER_COMMIT_ID=$ORTHANC_INDEXER_COMMIT_ID \
    --build-arg ORTHANC_TCIA_COMMIT_ID=$ORTHANC_TCIA_COMMIT_ID \
    --build-arg ORTHANC_STONE_VIEWER_COMMIT_ID=$ORTHANC_STONE_VIEWER_COMMIT_ID \
    --build-arg ORTHANC_AZURE_STORAGE_COMMIT_ID=$ORTHANC_AZURE_STORAGE_COMMIT_ID \
    --build-arg ORTHANC_GOOGLE_STORAGE_COMMIT_ID=$ORTHANC_GOOGLE_STORAGE_COMMIT_ID \
    --build-arg ORTHANC_AWS_STORAGE_COMMIT_ID=$ORTHANC_AWS_STORAGE_COMMIT_ID \
    $base_image_tag_arg \
    $from_cache \
    $to_cache \
    -f docker/orthanc/Dockerfile  docker/orthanc/

elif [[ $push == "1" ]]; then

    docker tag osimis/orthanc:current osimis/orthanc:$branchTagName
    docker push osimis/orthanc:$branchTagName

fi

