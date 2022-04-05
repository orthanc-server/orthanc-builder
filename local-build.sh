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
currentTag=current
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
echo "currentTag       = $currentTag"
echo "pushTag          = $pushTag"


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

    # when building locally, use Docker builder (easier to reuse local images)
    build="build"
    push_load_arg=
else
    from_cache_arg_runner_base="--cache-from=osimis/orthanc-runner-base:cache-$currentTag"
    to_cache_arg_runner_base="--cache-to=osimis/orthanc-runner-base:cache-$currentTag"

    from_cache_arg_builder_base="--cache-from=osimis/orthanc-builder-base:cache-$currentTag"
    to_cache_arg_builder_base="--cache-to=osimis/orthanc-builder-base:cache-$currentTag"

    from_cache_arg_builder_vcpkg="--cache-from=osimis/orthanc-builder-base:cache-vcpkg-$currentTag"
    to_cache_arg_builder_vcpkg="--cache-to=osimis/orthanc-builder-base:cache-vcpkg-$currentTag"

    from_cache_arg_builder_vcpkg_azure="--cache-from=osimis/orthanc-builder-base:cache-vcpkg-azure-$currentTag"
    to_cache_arg_builder_vcpkg_azure="--cache-to=osimis/orthanc-builder-base:cache-vcpkg-azure-$currentTag"

    from_cache_arg_builder_vcpkg_google="--cache-from=osimis/orthanc-builder-base:cache-vcpkg-google-$currentTag"
    to_cache_arg_builder_vcpkg_google="--cache-to=osimis/orthanc-builder-base:cache-vcpkg-google-$currentTag"

    from_cache_arg="--cache-from=osimis/orthanc-builder-base:cache-main-$currentTag"
    to_cache_arg="--cache-to=osimis/orthanc-builder-base:cache-main-$currentTag"

    # when building in CI, use buildx
    build="buildx build"
    push_load_arg="--push"
fi

# runner_base_tag=$final_image_temporary_tag
# builder_base_tag=$final_image_temporary_tag
# builder_vcpkg_tag="vcpkg-$final_image_temporary_tag"
# builder_vcpkg_azure_tag="vcpkg-azure-$final_image_temporary_tag"
# builder_vcpkg_google_tag="vcpkg-google-$final_image_temporary_tag"


###### runner-base
docker $build \
    --progress=plain --platform=$platform -t osimis/orthanc-runner-base:$currentTag \
    $from_cache_arg_runner_base \
    $to_cache_arg_runner_base \
    $push_load_arg \
    -f docker/orthanc/Dockerfile.runner-base docker/orthanc

###### builder-base
docker $build \
    --progress=plain --platform=$platform -t osimis/orthanc-builder-base:$currentTag \
    $from_cache_arg_builder_base \
    $to_cache_arg_builder_base \
    $push_load_arg \
    --build-arg BASE_IMAGE_TAG=$currentTag \
    -f docker/orthanc/Dockerfile.builder-base docker/orthanc

###### builder-base-vcpkg
docker $build \
    --progress=plain --platform=$platform -t osimis/orthanc-builder-base:vcpkg-$currentTag \
    $from_cache_arg_builder_vcpkg \
    $to_cache_arg_builder_vcpkg \
    $push_load_arg \
    --build-arg BASE_IMAGE_TAG=$currentTag \
    -f docker/orthanc/Dockerfile.builder-vcpkg --target orthanc-build-vcpkg docker/orthanc

###### builder-base-vcpkg-azure
docker $build \
    --progress=plain --platform=$platform -t osimis/orthanc-builder-base:vcpkg-azure-$currentTag \
    $from_cache_arg_builder_vcpkg_azure \
    $to_cache_arg_builder_vcpkg_azure \
    $push_load_arg \
    --build-arg BASE_IMAGE_TAG=$currentTag \
    -f docker/orthanc/Dockerfile.builder-vcpkg --target orthanc-build-vcpkg-azure docker/orthanc

###### builder-base-vcpkg-google
docker $build \
    --progress=plain --platform=$platform -t osimis/orthanc-builder-base:vcpkg-google-$currentTag \
    $from_cache_arg_builder_vcpkg_google \
    $to_cache_arg_builder_vcpkg_google \
    $push_load_arg \
    --build-arg BASE_IMAGE_TAG=$currentTag \
    -f docker/orthanc/Dockerfile.builder-vcpkg --target orthanc-build-vcpkg-google docker/orthanc


if [[ $step == "push" ]]; then

    final_tag=$pushTag

else

    final_tag=$currentTag

fi

###### osimis/orthanc
docker $build \
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
    --build-arg BASE_IMAGE_TAG=$currentTag \
    $from_cache_arg \
    $to_cache_arg \
    $push_load_arg \
    -f docker/orthanc/Dockerfile  docker/orthanc/


