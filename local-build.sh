set -ex

# example
# To build locally:
# ./local-build.sh 
# ./local-build.sh version=unstable skipCommitChecks=1
# ./local-build.sh version=unstable skipCommitChecks=1 image=full
# To build from CI:
# ./local-build.sh version=stable platform=linux/amd64 type=ci step=push pushTag=22.4.0
# TO build locally on ARM64
# ./local-build.sh skipCommitChecks=1 platform=linux/arm64 image=normal

source bash-helpers.sh

# default arg values
version=stable
skipCommitChecks=0
platform=linux/amd64
type=local
step=build
currentTag=current
pushTag=unknown
image=normal


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
echo "image            = $image"

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
ORTHANC_NEURO_COMMIT_ID=$(getCommitId "Orthanc-neuro" $version docker $skipCommitChecks)
ORTHANC_TCIA_COMMIT_ID=$(getCommitId "Orthanc-tcia" $version docker $skipCommitChecks)
ORTHANC_STONE_VIEWER_COMMIT_ID=$(getCommitId "Orthanc-stone" $version docker $skipCommitChecks)
ORTHANC_AZURE_STORAGE_COMMIT_ID=$(getCommitId "Orthanc-azure-storage" $version docker $skipCommitChecks)
ORTHANC_GOOGLE_STORAGE_COMMIT_ID=$(getCommitId "Orthanc-google-storage" $version docker $skipCommitChecks)
ORTHANC_AWS_STORAGE_COMMIT_ID=$(getCommitId "Orthanc-aws-storage" $version docker $skipCommitChecks)
ORTHANC_OE2_COMMIT_ID=$(getCommitId "Orthanc-explorer-2" $version docker $skipCommitChecks)
ORTHANC_OE2_VERSION=$(getBranchTagToBuildDocker "Orthanc-explorer-2" $version)
ORTHANC_VOLVIEW_COMMIT_ID=$(getCommitId "Orthanc-volview" $version docker $skipCommitChecks)
ORTHANC_OHIF_COMMIT_ID=$(getCommitId "Orthanc-ohif" $version docker $skipCommitChecks)

BASE_DEBIAN_IMAGE=bullseye-20230522-slim
BASE_BUILDER_IMAGE_TAG=$BASE_DEBIAN_IMAGE-$version

# list all intermediate targets.  It allows us to "slow down" the build and see what's going wrong (which is not possible with 10 parallel builds)
buildTargets="build-plugin-auth build-orthanc build-gdcm build-plugin-pg build-plugin-mysql build-plugin-transfers build-plugin-dicomweb build-plugin-wsi build-plugin-owv build-plugin-python build-plugin-odbc build-plugin-indexer build-plugin-neuro build-plugin-tcia build-stone-viewer build-s3-object-storage build-oe2 build-plugin-volview build-plugin-ohif"

# by default, we try to build only the normal image (oposed to the full image with vcpkg and MSSQL drivers)
finalImageTarget=orthanc-no-vcpkg
if [[ $image == "full" ]]; then
    finalImageTarget=orthanc-with-vcpkg
fi

buildTargets="$buildTargets $finalImageTarget"

# to debug a particular build, you can hardcode the target hereunder (don't commit that !)
# buildTargets=build-plugin-neuro


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

    prefer_downloads=1
    enable_upload=0
else
    from_cache_arg_runner_base="--cache-from=osimis/orthanc-runner-base:cache-$BASE_BUILDER_IMAGE_TAG"
    to_cache_arg_runner_base="--cache-to=osimis/orthanc-runner-base:cache-$BASE_BUILDER_IMAGE_TAG"

    from_cache_arg_builder_base="--cache-from=osimis/orthanc-builder-base:cache-$BASE_BUILDER_IMAGE_TAG"
    to_cache_arg_builder_base="--cache-to=osimis/orthanc-builder-base:cache-$BASE_BUILDER_IMAGE_TAG"

    from_cache_arg_builder_vcpkg="--cache-from=osimis/orthanc-builder-base:cache-vcpkg-$BASE_BUILDER_IMAGE_TAG"
    to_cache_arg_builder_vcpkg="--cache-to=osimis/orthanc-builder-base:cache-vcpkg-$BASE_BUILDER_IMAGE_TAG"

    from_cache_arg_builder_vcpkg_azure="--cache-from=osimis/orthanc-builder-base:cache-vcpkg-azure-$BASE_BUILDER_IMAGE_TAG"
    to_cache_arg_builder_vcpkg_azure="--cache-to=osimis/orthanc-builder-base:cache-vcpkg-azure-$BASE_BUILDER_IMAGE_TAG"

    from_cache_arg_builder_vcpkg_google="--cache-from=osimis/orthanc-builder-base:cache-vcpkg-google-$BASE_BUILDER_IMAGE_TAG"
    to_cache_arg_builder_vcpkg_google="--cache-to=osimis/orthanc-builder-base:cache-vcpkg-google-$BASE_BUILDER_IMAGE_TAG"

    from_cache_arg="--cache-from=osimis/orthanc-builder-base:cache-main-$BASE_BUILDER_IMAGE_TAG"
    to_cache_arg="--cache-to=osimis/orthanc-builder-base:cache-main-$BASE_BUILDER_IMAGE_TAG"

    # when building in CI, use buildx
    build="buildx build"
    push_load_arg="--push"
    
    # when building in CI, don't use intermediate targets (it would push plenty of images)
    buildTargets=$finalImageTarget

    prefer_downloads=1
    enable_upload=1
fi


if [[ $step == "push" ]]; then

    if [[ $version == "unstable" ]]; then
        final_tag=$pushTag-unstable
    else
        final_tag=$pushTag
    fi

    # tag previously build images and push them
    docker tag osimis/orthanc:$currentTag osimis/orthanc:$final_tag
    docker push osimis/orthanc:$final_tag
    exit 0
else

    final_tag=$currentTag

fi


# runner_base_tag=$final_image_temporary_tag
# builder_base_tag=$final_image_temporary_tag
# builder_vcpkg_tag="vcpkg-$final_image_temporary_tag"
# builder_vcpkg_azure_tag="vcpkg-azure-$final_image_temporary_tag"
# builder_vcpkg_google_tag="vcpkg-google-$final_image_temporary_tag"

###### runner-base
docker $build \
    --progress=plain --platform=$platform -t osimis/orthanc-runner-base:$BASE_BUILDER_IMAGE_TAG \
    --build-arg BASE_DEBIAN_IMAGE=$BASE_DEBIAN_IMAGE \
    $from_cache_arg_runner_base \
    $to_cache_arg_runner_base \
    $push_load_arg \
    -f docker/orthanc/Dockerfile.runner-base docker/orthanc

###### builder-base
docker $build \
    --progress=plain --platform=$platform -t osimis/orthanc-builder-base:$BASE_BUILDER_IMAGE_TAG \
    $from_cache_arg_builder_base \
    $to_cache_arg_builder_base \
    $push_load_arg \
    --build-arg BASE_IMAGE_TAG=$BASE_BUILDER_IMAGE_TAG \
    -f docker/orthanc/Dockerfile.builder-base docker/orthanc

if [[ $image == "full" ]]; then

    ###### builder-base-vcpkg
    docker $build \
        --progress=plain --platform=$platform -t osimis/orthanc-builder-base:vcpkg-$BASE_BUILDER_IMAGE_TAG \
        $from_cache_arg_builder_vcpkg \
        $to_cache_arg_builder_vcpkg \
        $push_load_arg \
        --build-arg BASE_IMAGE_TAG=$BASE_BUILDER_IMAGE_TAG \
        -f docker/orthanc/Dockerfile.builder-vcpkg --target orthanc-build-vcpkg docker/orthanc

    ###### builder-base-vcpkg-azure
    docker $build \
        --progress=plain --platform=$platform -t osimis/orthanc-builder-base:vcpkg-azure-$BASE_BUILDER_IMAGE_TAG \
        $from_cache_arg_builder_vcpkg_azure \
        $to_cache_arg_builder_vcpkg_azure \
        $push_load_arg \
        --build-arg BASE_IMAGE_TAG=$BASE_BUILDER_IMAGE_TAG \
        -f docker/orthanc/Dockerfile.builder-vcpkg --target orthanc-build-vcpkg-azure docker/orthanc

    ###### builder-base-vcpkg-google
    docker $build \
        --progress=plain --platform=$platform -t osimis/orthanc-builder-base:vcpkg-google-$BASE_BUILDER_IMAGE_TAG \
        $from_cache_arg_builder_vcpkg_google \
        $to_cache_arg_builder_vcpkg_google \
        $push_load_arg \
        --build-arg BASE_IMAGE_TAG=$BASE_BUILDER_IMAGE_TAG \
        -f docker/orthanc/Dockerfile.builder-vcpkg --target orthanc-build-vcpkg-google docker/orthanc
fi


for target in $buildTargets; do

    if [[ $target == $finalImageTarget ]]; then
        tag_arg="--tag osimis/orthanc:$final_tag"
    else
        tag_arg=
    fi

    # sleep 5
    ###### osimis/orthanc
    docker $build \
        --progress=plain --platform=$platform \
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
        --build-arg ORTHANC_NEURO_COMMIT_ID=$ORTHANC_NEURO_COMMIT_ID \
        --build-arg ORTHANC_TCIA_COMMIT_ID=$ORTHANC_TCIA_COMMIT_ID \
        --build-arg ORTHANC_STONE_VIEWER_COMMIT_ID=$ORTHANC_STONE_VIEWER_COMMIT_ID \
        --build-arg ORTHANC_AZURE_STORAGE_COMMIT_ID=$ORTHANC_AZURE_STORAGE_COMMIT_ID \
        --build-arg ORTHANC_GOOGLE_STORAGE_COMMIT_ID=$ORTHANC_GOOGLE_STORAGE_COMMIT_ID \
        --build-arg ORTHANC_AWS_STORAGE_COMMIT_ID=$ORTHANC_AWS_STORAGE_COMMIT_ID \
        --build-arg ORTHANC_OE2_COMMIT_ID=$ORTHANC_OE2_COMMIT_ID \
        --build-arg ORTHANC_OE2_VERSION=$ORTHANC_OE2_VERSION \
        --build-arg ORTHANC_VOLVIEW_COMMIT_ID=$ORTHANC_VOLVIEW_COMMIT_ID \
        --build-arg ORTHANC_OHIF_COMMIT_ID=$ORTHANC_OHIF_COMMIT_ID \
        --build-arg BASE_IMAGE_TAG=$BASE_BUILDER_IMAGE_TAG \
        --build-arg ARG_AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
        --build-arg ARG_AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
        --build-arg PREFER_DOWNLOADS=$prefer_downloads \
        --build-arg ENABLE_UPLOAD=$enable_upload \
        --build-arg PLATFORM=$platform \
        --build-arg STABLE_OR_UNSTABLE=$version \
        $from_cache_arg \
        $to_cache_arg \
        $push_load_arg \
        $tag_arg \
        --target $target \
        -f docker/orthanc/Dockerfile  docker/orthanc/

done
