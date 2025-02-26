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
isTag=false
useBuildx=false
throttle=0

for argument in "$@"
do
   key=$(echo $argument | cut -f1 -d=)

   key_length=${#key}
   value="${argument:$key_length+1}"

   export "$key"="$value"
done

if [[ $type == "ci" ]]; then
    if [[ $platform == "linux/amd64" ]]; then
        useBuildx=true
    fi
    throttle=1
fi

if [[ $platform == "linux/amd64" ]]; then
    shortPlatform="amd64"
else
    shortPlatform="arm64"
fi


arch=$(echo $platform | cut -d '/' -f 2)

echo "version          = $version"
echo "platform         = $platform"
echo "shortPlatform    = $shortPlatform"
echo "type             = $type"
echo "skipCommitChecks = $skipCommitChecks"
echo "step             = $step"
echo "currentTag       = $currentTag"
echo "pushTag          = $pushTag"
echo "image            = $image"

# get version number from build-matrix.json (stable or unstable)
# note: we get the last commit id from a branch to detect last changes in a branch

ORTHANC_COMMIT_ID=$(getCommitId "Orthanc" $version docker $skipCommitChecks $throttle)
ORTHANC_GDCM_COMMIT_ID=$(getCommitId "Orthanc-gdcm" $version docker $skipCommitChecks $throttle)
ORTHANC_PG_COMMIT_ID=$(getCommitId "Orthanc-postgresql" $version docker $skipCommitChecks $throttle)
ORTHANC_MYSQL_COMMIT_ID=$(getCommitId "Orthanc-mysql" $version docker $skipCommitChecks $throttle)
ORTHANC_TRANSFERS_COMMIT_ID=$(getCommitId "Orthanc-transfers" $version docker $skipCommitChecks $throttle)
ORTHANC_DW_COMMIT_ID=$(getCommitId "Orthanc-dicomweb" $version docker $skipCommitChecks $throttle)
ORTHANC_WSI_COMMIT_ID=$(getCommitId "Orthanc-wsi" $version docker $skipCommitChecks $throttle)
ORTHANC_OWV_COMMIT_ID=$(getCommitId "Orthanc-webviewer" $version docker $skipCommitChecks $throttle)
ORTHANC_AUTH_COMMIT_ID=$(getCommitId "Orthanc-auth" $version docker $skipCommitChecks $throttle)
ORTHANC_PYTHON_COMMIT_ID=$(getCommitId "Orthanc-python" $version docker $skipCommitChecks $throttle)
ORTHANC_ODBC_COMMIT_ID=$(getCommitId "Orthanc-odbc" $version docker $skipCommitChecks $throttle)
ORTHANC_INDEXER_COMMIT_ID=$(getCommitId "Orthanc-indexer" $version docker $skipCommitChecks $throttle)
ORTHANC_NEURO_COMMIT_ID=$(getCommitId "Orthanc-neuro" $version docker $skipCommitChecks $throttle)
ORTHANC_TCIA_COMMIT_ID=$(getCommitId "Orthanc-tcia" $version docker $skipCommitChecks $throttle)
ORTHANC_STONE_VIEWER_COMMIT_ID=$(getCommitId "Orthanc-stone" $version docker $skipCommitChecks $throttle)
ORTHANC_AZURE_STORAGE_COMMIT_ID=$(getCommitId "Orthanc-azure-storage" $version docker $skipCommitChecks $throttle)
ORTHANC_GOOGLE_STORAGE_COMMIT_ID=$(getCommitId "Orthanc-google-storage" $version docker $skipCommitChecks $throttle)
ORTHANC_AWS_STORAGE_COMMIT_ID=$(getCommitId "Orthanc-aws-storage" $version docker $skipCommitChecks $throttle)
ORTHANC_OE2_COMMIT_ID=$(getCommitId "Orthanc-explorer-2" $version docker $skipCommitChecks $throttle)
ORTHANC_OE2_VERSION=$(getBranchTagToBuildDocker "Orthanc-explorer-2" $version $throttle)
ORTHANC_VOLVIEW_COMMIT_ID=$(getCommitId "Orthanc-volview" $version docker $skipCommitChecks $throttle)
ORTHANC_OHIF_COMMIT_ID=$(getCommitId "Orthanc-ohif" $version docker $skipCommitChecks $throttle)
ORTHANC_STL_COMMIT_ID=$(getCommitId "Orthanc-stl" $version docker $skipCommitChecks $throttle)
ORTHANC_JAVA_COMMIT_ID=$(getCommitId "Orthanc-java" $version docker $skipCommitChecks $throttle)

BASE_DEBIAN_IMAGE=bookworm-20250224-slim
BASE_BUILDER_IMAGE_TAG=$BASE_DEBIAN_IMAGE-$version

# list all intermediate targets.  It allows us to "slow down" the build and see what's going wrong (which is not possible with 10 parallel builds)
buildTargets="build-plugin-java build-plugin-auth build-orthanc build-gdcm build-plugin-pg build-plugin-mysql build-plugin-transfers build-plugin-dicomweb build-plugin-wsi build-plugin-owv build-plugin-python build-plugin-odbc build-plugin-indexer build-plugin-neuro build-plugin-tcia build-s3-object-storage build-oe2 build-plugin-volview build-plugin-ohif build-plugin-stl"

# by default, we try to build only the normal image (oposed to the full image with vcpkg and MSSQL drivers)
finalImageTarget=orthanc-no-vcpkg
if [[ $image == "full" ]]; then
    finalImageTarget=orthanc-with-vcpkg
fi

buildTargets="$buildTargets $finalImageTarget"

# to debug a particular build, you can hardcode the target hereunder (don't commit that !)
# buildTargets=build-plugin-java

if [[ $useBuildx == "true" ]]; then
    from_cache_arg_runner_base="--cache-from=orthancteam/orthanc-runner-base:cache-$BASE_BUILDER_IMAGE_TAG"
    to_cache_arg_runner_base="--cache-to=orthancteam/orthanc-runner-base:cache-$BASE_BUILDER_IMAGE_TAG"

    from_cache_arg_builder_base="--cache-from=orthancteam/orthanc-builder-base:cache-$BASE_BUILDER_IMAGE_TAG"
    to_cache_arg_builder_base="--cache-to=orthancteam/orthanc-builder-base:cache-$BASE_BUILDER_IMAGE_TAG"

    from_cache_arg_builder_vcpkg="--cache-from=orthancteam/orthanc-builder-base:cache-vcpkg-$BASE_BUILDER_IMAGE_TAG"
    to_cache_arg_builder_vcpkg="--cache-to=orthancteam/orthanc-builder-base:cache-vcpkg-$BASE_BUILDER_IMAGE_TAG"

    from_cache_arg_builder_vcpkg_azure="--cache-from=orthancteam/orthanc-builder-base:cache-vcpkg-azure-$BASE_BUILDER_IMAGE_TAG"
    to_cache_arg_builder_vcpkg_azure="--cache-to=orthancteam/orthanc-builder-base:cache-vcpkg-azure-$BASE_BUILDER_IMAGE_TAG"

    from_cache_arg_builder_vcpkg_google="--cache-from=orthancteam/orthanc-builder-base:cache-vcpkg-google-$BASE_BUILDER_IMAGE_TAG"
    to_cache_arg_builder_vcpkg_google="--cache-to=orthancteam/orthanc-builder-base:cache-vcpkg-google-$BASE_BUILDER_IMAGE_TAG"

    from_cache_arg="--cache-from=orthancteam/orthanc-builder-base:cache-main-$BASE_BUILDER_IMAGE_TAG"
    to_cache_arg="--cache-to=orthancteam/orthanc-builder-base:cache-main-$BASE_BUILDER_IMAGE_TAG"

    # when building in CI, use buildx
    build="buildx build"
    push_load_arg_final_image="--load"
    push_load_arg_builder_image="--push"
    if [[ $step == "push" ]]; then
        push_load_arg_final_image="--push"
        push_load_arg_builder_image=
    fi
    
else

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
    push_load_arg_final_image=
    push_load_arg_builder_image=

fi


if [[ $type == "local" ]]; then

    prefer_downloads=1
    enable_upload=0
else

    # when building in CI, don't use intermediate targets (it would push plenty of images)
    buildTargets=$finalImageTarget

    prefer_downloads=1
    enable_upload=1
fi


if [[ $step == "push" ]]; then

    # push to orthancteam/orthanc-pre-release only.  The manifest will be pushed to orthancteam/orthanc
    if [[ $isTag == "true" ]] && [[ $version == "stable" ]]; then
        final_tag=$pushTag-$arch
    else
        # otherwise we push to orthancteam/orthanc-pre-release

        if [[ $version == "unstable" ]]; then
            final_tag=$pushTag-unstable-$arch
        else
            final_tag=$pushTag-$arch
        fi
    fi

    # tag previously built images and push them
    docker tag orthancteam/orthanc:$currentTag orthancteam/orthanc-pre-release:$final_tag
    docker push orthancteam/orthanc-pre-release:$final_tag

    exit 0
else

    final_tag=$currentTag

fi

if [[ $step == "publish-manifest" ]]; then

    # push to orthancteam/orthanc only if it is a tag and if it is the stable version !!!! to keep the DockerHub tags clean !
    if [[ $isTag == "true" ]] && [[ $version == "stable" ]]; then
        final_tag=$pushTag
        final_image=orthancteam/orthanc
    else
        # otherwise we push to orthancteam/orthanc-pre-release

        if [[ $version == "unstable" ]]; then
            final_tag=$pushTag-unstable
        else
            final_tag=$pushTag
        fi
        final_image=orthancteam/orthanc-pre-release
    fi

    # this step merges the AMD64 and ARM64 images into a single manifest
    docker manifest rm $final_image:$final_tag || true
    docker manifest create $final_image:$final_tag orthancteam/orthanc-pre-release:$final_tag-amd64 orthancteam/orthanc-pre-release:$final_tag-arm64
    docker manifest annotate $final_image:$final_tag orthancteam/orthanc-pre-release:$final_tag-amd64 --os linux --arch amd64
    docker manifest annotate $final_image:$final_tag orthancteam/orthanc-pre-release:$final_tag-arm64 --os linux --arch arm64
    docker manifest push $final_image:$final_tag

    exit 0
fi

# runner_base_tag=$final_image_temporary_tag
# builder_base_tag=$final_image_temporary_tag
# builder_vcpkg_tag="vcpkg-$final_image_temporary_tag"
# builder_vcpkg_azure_tag="vcpkg-azure-$final_image_temporary_tag"
# builder_vcpkg_google_tag="vcpkg-google-$final_image_temporary_tag"

add_host_cmd=--add-host=orthanc.uclouvain.be:130.104.229.21

###### runner-base
docker $build \
    $add_host_cmd \
    --progress=plain --platform=$platform -t orthancteam/orthanc-runner-base:$BASE_BUILDER_IMAGE_TAG \
    --build-arg BASE_DEBIAN_IMAGE=$BASE_DEBIAN_IMAGE \
    $from_cache_arg_runner_base \
    $to_cache_arg_runner_base \
    $push_load_arg_builder_image \
    -f docker/orthanc/Dockerfile.runner-base docker/orthanc

###### builder-base
docker $build \
    $add_host_cmd \
    --progress=plain --platform=$platform -t orthancteam/orthanc-builder-base:$BASE_BUILDER_IMAGE_TAG \
    $from_cache_arg_builder_base \
    $to_cache_arg_builder_base \
    $push_load_arg_builder_image \
    --build-arg BASE_IMAGE_TAG=$BASE_BUILDER_IMAGE_TAG \
    -f docker/orthanc/Dockerfile.builder-base docker/orthanc

if [[ $image == "full" ]]; then

    ###### builder-base-vcpkg
    docker $build \
        $add_host_cmd \
        --progress=plain --platform=$platform -t orthancteam/orthanc-builder-base:vcpkg-$BASE_BUILDER_IMAGE_TAG \
        $from_cache_arg_builder_vcpkg \
        $to_cache_arg_builder_vcpkg \
        $push_load_arg_builder_image \
        --build-arg BASE_IMAGE_TAG=$BASE_BUILDER_IMAGE_TAG \
        -f docker/orthanc/Dockerfile.builder-vcpkg --target orthanc-build-vcpkg docker/orthanc

    ###### builder-base-vcpkg-azure
    docker $build \
        $add_host_cmd \
        --progress=plain --platform=$platform -t orthancteam/orthanc-builder-base:vcpkg-azure-$BASE_BUILDER_IMAGE_TAG \
        $from_cache_arg_builder_vcpkg_azure \
        $to_cache_arg_builder_vcpkg_azure \
        $push_load_arg_builder_image \
        --build-arg BASE_IMAGE_TAG=$BASE_BUILDER_IMAGE_TAG \
        -f docker/orthanc/Dockerfile.builder-vcpkg --target orthanc-build-vcpkg-azure docker/orthanc

    ###### builder-base-vcpkg-google
    docker $build \
        $add_host_cmd \
        --progress=plain --platform=$platform -t orthancteam/orthanc-builder-base:vcpkg-google-$BASE_BUILDER_IMAGE_TAG \
        $from_cache_arg_builder_vcpkg_google \
        $to_cache_arg_builder_vcpkg_google \
        $push_load_arg_builder_image \
        --build-arg BASE_IMAGE_TAG=$BASE_BUILDER_IMAGE_TAG \
        -f docker/orthanc/Dockerfile.builder-vcpkg --target orthanc-build-vcpkg-google docker/orthanc
fi


for target in $buildTargets; do

    if [[ $target == $finalImageTarget ]]; then
        tag_arg="--tag orthancteam/orthanc:$final_tag"
    else
        tag_arg=
    fi

    # sleep 5
    ###### orthancteam/orthanc
    docker $build \
        $add_host_cmd \
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
        --build-arg ORTHANC_STL_COMMIT_ID=$ORTHANC_STL_COMMIT_ID \
        --build-arg ORTHANC_JAVA_COMMIT_ID=$ORTHANC_JAVA_COMMIT_ID \
        --build-arg BASE_IMAGE_TAG=$BASE_BUILDER_IMAGE_TAG \
        --build-arg ARG_AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
        --build-arg ARG_AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
        --build-arg PREFER_DOWNLOADS=$prefer_downloads \
        --build-arg ENABLE_UPLOAD=$enable_upload \
        --build-arg PLATFORM=$platform \
        --build-arg STONE_INTERMEDIATE_TARGET=build-stone-viewer-$shortPlatform \
        --build-arg STABLE_OR_UNSTABLE=$version \
        $from_cache_arg \
        $to_cache_arg \
        $push_load_arg_final_image \
        $tag_arg \
        --target $target \
        -f docker/orthanc/Dockerfile  docker/orthanc/

done
