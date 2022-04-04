set -ex

# example
# To build locally:
# ./local-build.sh 
# ./local-build.sh version=unstable skipCommitChecks=1
# To build from CI:
# ./local-build.sh version=stable platform=linux/amd64 type=ci step=push pushTag=22.3.0

source bash-helpers.sh

# default arg values
version=stable
skipCommitChecks=0
platform=linux/amd64
type=local
step=build
pushTag=unknown

for argument in "$@"
do
   key=$(echo $argument | cut -f1 -d=)

   key_length=${#key}
   value="${argument:$key_length+1}"

   export "$key"="$value"
done

echo "version          = $version"
echo "platform         = $platform"
echo "type             = $type"
echo "skipCommitChecks = $skipCommitChecks"
echo "step             = $step"
echo "pushTag          = $pushTag"

debian_base_version="bullseye-20220125"
final_image_temporary_tag="current-$debian_base_version"



# get version number from build-matrix.json (stable or unstable)
# note: we get the last commit id from a branch to detect last changes in a branch

ORTHANC_COMMIT_ID=$(getCommitId "Orthanc" $version docker $skipCommitChecks)
ORTHANC_GDCM_COMMIT_ID=$(getCommitId "Orthanc-gdcm" $version docker $skipCommitChecks)
ORTHANC_PG_COMMIT_ID=$(getCommitId "Orthanc-postgresql" $version docker $skipCommitChecks)
ORTHANC_MYSQL_COMMIT_ID=$(getCommitId "Orthanc-mysql" $version docker $skipCommitChecks)
ORTHANC_TRANSFERS_COMMIT_ID=$(getCommitId "Orthanc-transfers" $version docker $skipCommitChecks)
ORTHANC_DW_COMMIT_ID=$(getCommitId "Orthanc-dicomweb" $version docker $skipCommitChecks)
ORTHANC_WSI_COMMIT_ID=$(getCommitId "Orthanc-wsi" $version docker $skipCommitChecks)
ORTHANC_OWV_COMMIT_ID=$(getCommitId "Orthanc-webviewer" $version docker $skipCommitChecks)
ORTHANC_AUTH_COMMIT_ID=$(getCommitId "Orthanc-auth" $version docker $skipCommitChecks)
ORTHANC_PYTHON_COMMIT_ID=$(getCommitId "Orthanc-python" $version docker $skipCommitChecks)
ORTHANC_ODBC_COMMIT_ID=$(getCommitId "Orthanc-odbc" $version docker $skipCommitChecks)
ORTHANC_INDEXER_COMMIT_ID=$(getCommitId "Orthanc-indexer" $version docker $skipCommitChecks)
ORTHANC_TCIA_COMMIT_ID=$(getCommitId "Orthanc-tcia" $version docker $skipCommitChecks)
ORTHANC_STONE_VIEWER_COMMIT_ID=$(getCommitId "Orthanc-stone" $version docker $skipCommitChecks)
ORTHANC_AZURE_STORAGE_COMMIT_ID=$(getCommitId "Orthanc-azure-storage" $version docker $skipCommitChecks)
ORTHANC_GOOGLE_STORAGE_COMMIT_ID=$(getCommitId "Orthanc-google-storage" $version docker $skipCommitChecks)
ORTHANC_AWS_STORAGE_COMMIT_ID=$(getCommitId "Orthanc-aws-storage" $version docker $skipCommitChecks)

if [[ $type == "local" ]]; then
    from_cache_arg_runner_base=
    to_cache_arg_runner_base=

    from_cache_arg_builder_base=
    to_cache_arg_builder_base=

    from_cache_arg_builder_vcpkg=
    to_cache_arg_builder_vcpkg=

    from_cache_arg_builder_vcpkg_azure=
    to_cache_arg_builder_vcpkg_azure=

    from_cache_arg_builder_vcpkg_google=
    to_cache_arg_builder_vcpkg_google=

    from_cache_arg=
    to_cache_arg=

    push_arg=
else
    from_cache_arg_runner_base="--cache-from=osimis/orthanc-runner-base:cache-$version"
    to_cache_arg_runner_base="--cache-to=osimis/orthanc-runner-base:cache-$version"

    from_cache_arg_builder_base="--cache-from=osimis/orthanc-builder-base:cache-$version"
    to_cache_arg_builder_base="--cache-to=osimis/orthanc-builder-base:cache-$version"

    from_cache_arg_builder_vcpkg="--cache-from=osimis/orthanc-builder-base:cache-vcpkg-$version"
    to_cache_arg_builder_vcpkg="--cache-to=osimis/orthanc-builder-base:cache-vcpkg-$version"

    from_cache_arg_builder_vcpkg_azure="--cache-from=osimis/orthanc-builder-base:cache-vcpkg-azure-$version"
    to_cache_arg_builder_vcpkg_azure="--cache-to=osimis/orthanc-builder-base:cache-vcpkg-azure-$version"

    from_cache_arg_builder_vcpkg_google="--cache-from=osimis/orthanc-builder-base:cache-vcpkg-google-$version"
    to_cache_arg_builder_vcpkg_google="--cache-to=osimis/orthanc-builder-base:cache-vcpkg-google-$version"

    from_cache_arg="--cache-from=osimis/orthanc-builder-base:cache-main-$version"
    to_cache_arg="--cache-to=osimis/orthanc-builder-base:cache-main-$version"

    push_arg="--push"
fi

runner_base_tag=$debian_base_version
builder_base_tag=$debian_base_version
builder_vcpkg_tag="vcpkg-$debian_base_version"
builder_vcpkg_azure_tag="vcpkg-azure-$debian_base_version"
builder_vcpkg_google_tag="vcpkg-google-$debian_base_version"


###### runner-base
docker buildx build \
    --progress=plain --platform=$platform -t osimis/orthanc-runner-base:$runner_base_tag \
    --build-arg BASE_IMAGE_TAG=$debian_base_version \
    $from_cache_arg_runner_base \
    $to_cache_arg_runner_base \
    $push_arg \
    -f docker/orthanc/Dockerfile.runner-base docker/orthanc

###### builder-base
docker buildx build \
    --progress=plain --platform=$platform -t osimis/orthanc-builder-base:$builder_base_tag \
    $from_cache_arg_builder_base \
    $to_cache_arg_builder_base \
    $push_arg \
    --build-arg BASE_IMAGE_TAG=$debian_base_version \
    -f docker/orthanc/Dockerfile.builder-base docker/orthanc

###### builder-base-vcpkg
docker buildx build \
    --progress=plain --platform=$platform -t osimis/orthanc-builder-base:$builder_vcpkg_tag \
    $from_cache_arg_builder_vcpkg \
    $to_cache_arg_builder_vcpkg \
    $push_arg \
    --build-arg BASE_IMAGE_TAG=$debian_base_version \
    -f docker/orthanc/Dockerfile.builder-vcpkg --target orthanc-build-vcpkg docker/orthanc

###### builder-base-vcpkg-azure
docker buildx build \
    --progress=plain --platform=$platform -t osimis/orthanc-builder-base:$builder_vcpkg_azure_tag \
    $from_cache_arg_builder_vcpkg_azure \
    $to_cache_arg_builder_vcpkg_azure \
    $push_arg \
    --build-arg BASE_IMAGE_TAG=$debian_base_version \
    -f docker/orthanc/Dockerfile.builder-vcpkg --target orthanc-build-vcpkg-azure docker/orthanc

###### builder-base-vcpkg-google
docker buildx build \
    --progress=plain --platform=$platform -t osimis/orthanc-builder-base:$builder_vcpkg_google_tag \
    $from_cache_arg_builder_vcpkg_google \
    $to_cache_arg_builder_vcpkg_google \
    $push_arg \
    --build-arg BASE_IMAGE_TAG=$debian_base_version \
    -f docker/orthanc/Dockerfile.builder-vcpkg --target orthanc-build-vcpkg-google docker/orthanc


if [[ $step == "push" ]]; then

    final_tag=$pushTag

else

    final_tag=$final_image_temporary_tag

fi

###### osimis/orthanc
docker buildx build \
    --progress=plain --platform=$platform -t osimis/orthanc:$final_tag \
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
    --build-arg BASE_IMAGE_TAG=$debian_base_version \
    $from_cache \
    $to_cache \
    $push_arg \
    -f docker/orthanc/Dockerfile  docker/orthanc/


