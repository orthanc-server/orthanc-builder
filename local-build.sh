set -ex

# example
# To build locally:
# ./local-build.sh 
# ./local-build.sh version=unstable getCommitIdsFromFile=1
# ./local-build.sh version=unstable skipCommitChecks=1 image=full
# To build from CI:
# ./local-build.sh version=stable platform=linux/amd64 type=ci step=push pushTag=22.4.0
# TO build locally on ARM64
# ./local-build.sh skipCommitChecks=1 platform=linux/arm64 image=normal
# TO populate commit id matrix
# ./local-build.sh step=generate-commit-id-matrix version=unstable

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
getCommitIdsFromFile=false
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
echo "getCommitIdsFromFile = $getCommitIdsFromFile"
echo "useBuildx        = $useBuildx"
echo "throttle         = $throttle"



if [[ $step == "push-before-test-image" ]]; then

    # tag previously built images and push
    docker tag orthancteam/orthanc:$currentTag orthancteam/orthanc-pre-release:$currentTag-before-tests-$shortPlatform
    docker push orthancteam/orthanc-pre-release:$currentTag-before-tests-$shortPlatform

    exit 0
fi

if [[ $step == "pull-before-test-image" ]]; then

    docker pull orthancteam/orthanc-pre-release:$currentTag-before-tests-$shortPlatform
    exit 0
fi

if [[ $step == "pull-tag-push" ]]; then

    docker pull orthancteam/orthanc-pre-release:$currentTag-before-tests-$shortPlatform
    docker tag orthancteam/orthanc-pre-release:$currentTag-before-tests-$shortPlatform orthancteam/orthanc-pre-release:$currentTag-$shortPlatform
    docker push orthancteam/orthanc-pre-release:$currentTag-$shortPlatform

    exit 0
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
    docker manifest create $final_image:$final_tag orthancteam/orthanc-pre-release:$currentTag-amd64 orthancteam/orthanc-pre-release:$currentTag-arm64
    docker manifest annotate $final_image:$final_tag orthancteam/orthanc-pre-release:$currentTag-amd64 --os linux --arch amd64
    docker manifest annotate $final_image:$final_tag orthancteam/orthanc-pre-release:$currentTag-arm64 --os linux --arch arm64
    docker manifest push $final_image:$final_tag

    exit 0
fi


if [[ $step == "generate-commit-id-matrix" ]] || [[ $getCommitIdsFromFile == "false" ]]; then

    # get version number from build-matrix.json (stable or unstable)
    # note: we get the last commit id from a branch to detect last changes in a branch
    uploadToWebServer=1

    ORTHANC_COMMIT_ID=$(getCommitId "Orthanc" $version docker $skipCommitChecks $throttle $uploadToWebServer)
    ORTHANC_GDCM_COMMIT_ID=$(getCommitId "Orthanc-gdcm" $version docker $skipCommitChecks $throttle $uploadToWebServer)
    ORTHANC_PG_COMMIT_ID=$(getCommitId "Orthanc-postgresql" $version docker $skipCommitChecks $throttle $uploadToWebServer)
    ORTHANC_MYSQL_COMMIT_ID=$(getCommitId "Orthanc-mysql" $version docker $skipCommitChecks $throttle $uploadToWebServer)
    ORTHANC_TRANSFERS_COMMIT_ID=$(getCommitId "Orthanc-transfers" $version docker $skipCommitChecks $throttle $uploadToWebServer)
    ORTHANC_DW_COMMIT_ID=$(getCommitId "Orthanc-dicomweb" $version docker $skipCommitChecks $throttle $uploadToWebServer)
    ORTHANC_WSI_COMMIT_ID=$(getCommitId "Orthanc-wsi" $version docker $skipCommitChecks $throttle $uploadToWebServer)
    ORTHANC_OWV_COMMIT_ID=$(getCommitId "Orthanc-webviewer" $version docker $skipCommitChecks $throttle $uploadToWebServer)
    ORTHANC_AUTH_COMMIT_ID=$(getCommitId "Orthanc-auth" $version docker $skipCommitChecks $throttle $uploadToWebServer)
    ORTHANC_PYTHON_COMMIT_ID=$(getCommitId "Orthanc-python" $version docker $skipCommitChecks $throttle $uploadToWebServer)
    ORTHANC_ODBC_COMMIT_ID=$(getCommitId "Orthanc-odbc" $version docker $skipCommitChecks $throttle $uploadToWebServer)
    ORTHANC_INDEXER_COMMIT_ID=$(getCommitId "Orthanc-indexer" $version docker $skipCommitChecks $throttle $uploadToWebServer)
    ORTHANC_NEURO_COMMIT_ID=$(getCommitId "Orthanc-neuro" $version docker $skipCommitChecks $throttle $uploadToWebServer)
    ORTHANC_TCIA_COMMIT_ID=$(getCommitId "Orthanc-tcia" $version docker $skipCommitChecks $throttle $uploadToWebServer)
    ORTHANC_STONE_VIEWER_COMMIT_ID=$(getCommitId "Orthanc-stone" $version docker $skipCommitChecks $throttle $uploadToWebServer)
    ORTHANC_AZURE_STORAGE_COMMIT_ID=$(getCommitId "Orthanc-azure-storage" $version docker $skipCommitChecks $throttle $uploadToWebServer)
    ORTHANC_GOOGLE_STORAGE_COMMIT_ID=$(getCommitId "Orthanc-google-storage" $version docker $skipCommitChecks $throttle $uploadToWebServer)
    ORTHANC_AWS_STORAGE_COMMIT_ID=$(getCommitId "Orthanc-aws-storage" $version docker $skipCommitChecks $throttle $uploadToWebServer)
    ORTHANC_OE2_COMMIT_ID=$(getCommitId "Orthanc-explorer-2" $version docker $skipCommitChecks $throttle $uploadToWebServer)
    ORTHANC_OE2_VERSION=$(getBranchTagToBuildDocker "Orthanc-explorer-2" $version $throttle)
    ORTHANC_VOLVIEW_COMMIT_ID=$(getCommitId "Orthanc-volview" $version docker $skipCommitChecks $throttle $uploadToWebServer)
    ORTHANC_OHIF_COMMIT_ID=$(getCommitId "Orthanc-ohif" $version docker $skipCommitChecks $throttle $uploadToWebServer)
    ORTHANC_STL_COMMIT_ID=$(getCommitId "Orthanc-stl" $version docker $skipCommitChecks $throttle $uploadToWebServer)
    ORTHANC_JAVA_COMMIT_ID=$(getCommitId "Orthanc-java" $version docker $skipCommitChecks $throttle $uploadToWebServer)
    ORTHANC_ADVANCED_STORAGE_COMMIT_ID=$(getCommitId "Orthanc-advanced-storage" $version docker $skipCommitChecks $throttle $uploadToWebServer)
    ORTHANC_ADVANCED_STORAGE_VERSION=$(getBranchTagToBuildDocker "Orthanc-advanced-storage" $version $throttle)
    ORTHANC_WORKLISTS_COMMIT_ID=$(getCommitId "Orthanc-worklists" $version docker $skipCommitChecks $throttle $uploadToWebServer)
    ORTHANC_PIXELS_MASKER_COMMIT_ID=$(getCommitId "Orthanc-pixels-masker" $version docker $skipCommitChecks $throttle $uploadToWebServer)
    ORTHANC_EDUCATION_COMMIT_ID=$(getCommitId "Orthanc-education" $version docker $skipCommitChecks $throttle $uploadToWebServer)
    
    ORTHANC_TESTS_COMMIT_ID=$(getHgCommitId "https://orthanc.uclouvain.be/hg/orthanc-tests/" $(getIntegTestsRevision $version))
    if [[ $uploadToWebServer == "1" ]] && [[ $type == "ci" ]]; then
        upload_hg_repo_to_orthanc_team_if_not_already_there orthanc-tests $ORTHANC_TESTS_COMMIT_ID https://orthanc.uclouvain.be/hg/orthanc-tests/
    fi

    if [[ $version == "unstable" ]] && [[ $type == "ci" ]]; then
        wget https://public-files.orthanc.team/tmp-builds/hg-repos/orthanc-$ORTHANC_COMMIT_ID.tar.gz --output-document /tmp/orthanc-$ORTHANC_COMMIT_ID.tar.gz
        aws s3 --region eu-west-1 cp /tmp/orthanc-$ORTHANC_COMMIT_ID.tar.gz s3://public-files.orthanc.team/third-party-downloads/orthanc-framework/Orthanc-mainline.tar.gz --cache-control=max-age=1
    fi

    if [[ $step == "generate-commit-id-matrix" ]]; then
        cat <<EOF > /tmp/commit-ids-matrix-$version.json
{
"ORTHANC_COMMIT_ID": "$ORTHANC_COMMIT_ID",
"ORTHANC_GDCM_COMMIT_ID": "$ORTHANC_GDCM_COMMIT_ID",
"ORTHANC_PG_COMMIT_ID": "$ORTHANC_PG_COMMIT_ID",
"ORTHANC_MYSQL_COMMIT_ID": "$ORTHANC_MYSQL_COMMIT_ID",
"ORTHANC_TRANSFERS_COMMIT_ID": "$ORTHANC_TRANSFERS_COMMIT_ID",
"ORTHANC_DW_COMMIT_ID": "$ORTHANC_DW_COMMIT_ID",
"ORTHANC_WSI_COMMIT_ID": "$ORTHANC_WSI_COMMIT_ID",
"ORTHANC_OWV_COMMIT_ID": "$ORTHANC_OWV_COMMIT_ID",
"ORTHANC_AUTH_COMMIT_ID": "$ORTHANC_AUTH_COMMIT_ID",
"ORTHANC_PYTHON_COMMIT_ID": "$ORTHANC_PYTHON_COMMIT_ID",
"ORTHANC_ODBC_COMMIT_ID": "$ORTHANC_ODBC_COMMIT_ID",
"ORTHANC_INDEXER_COMMIT_ID": "$ORTHANC_INDEXER_COMMIT_ID",
"ORTHANC_NEURO_COMMIT_ID": "$ORTHANC_NEURO_COMMIT_ID",
"ORTHANC_TCIA_COMMIT_ID": "$ORTHANC_TCIA_COMMIT_ID",
"ORTHANC_STONE_VIEWER_COMMIT_ID": "$ORTHANC_STONE_VIEWER_COMMIT_ID",
"ORTHANC_AZURE_STORAGE_COMMIT_ID": "$ORTHANC_AZURE_STORAGE_COMMIT_ID",
"ORTHANC_GOOGLE_STORAGE_COMMIT_ID": "$ORTHANC_GOOGLE_STORAGE_COMMIT_ID",
"ORTHANC_AWS_STORAGE_COMMIT_ID": "$ORTHANC_AWS_STORAGE_COMMIT_ID",
"ORTHANC_OE2_COMMIT_ID": "$ORTHANC_OE2_COMMIT_ID",
"ORTHANC_OE2_VERSION": "$ORTHANC_OE2_VERSION",
"ORTHANC_VOLVIEW_COMMIT_ID": "$ORTHANC_VOLVIEW_COMMIT_ID",
"ORTHANC_OHIF_COMMIT_ID": "$ORTHANC_OHIF_COMMIT_ID",
"ORTHANC_STL_COMMIT_ID": "$ORTHANC_STL_COMMIT_ID",
"ORTHANC_JAVA_COMMIT_ID": "$ORTHANC_JAVA_COMMIT_ID",
"ORTHANC_ADVANCED_STORAGE_COMMIT_ID": "$ORTHANC_ADVANCED_STORAGE_COMMIT_ID",
"ORTHANC_ADVANCED_STORAGE_VERSION": "$ORTHANC_ADVANCED_STORAGE_VERSION",
"ORTHANC_WORKLISTS_COMMIT_ID": "$ORTHANC_WORKLISTS_COMMIT_ID",
"ORTHANC_PIXELS_MASKER_COMMIT_ID": "$ORTHANC_PIXELS_MASKER_COMMIT_ID",
"ORTHANC_EDUCATION_COMMIT_ID": "$ORTHANC_EDUCATION_COMMIT_ID",
"ORTHANC_TESTS_COMMIT_ID": "$ORTHANC_TESTS_COMMIT_ID"
}
EOF
        exit 0
    fi
else

    ORTHANC_COMMIT_ID=$(jq -r '.ORTHANC_COMMIT_ID' /tmp/commit-ids-matrix-$version.json)
    ORTHANC_GDCM_COMMIT_ID=$(jq -r '.ORTHANC_GDCM_COMMIT_ID' /tmp/commit-ids-matrix-$version.json)
    ORTHANC_PG_COMMIT_ID=$(jq -r '.ORTHANC_PG_COMMIT_ID' /tmp/commit-ids-matrix-$version.json)
    ORTHANC_MYSQL_COMMIT_ID=$(jq -r '.ORTHANC_MYSQL_COMMIT_ID' /tmp/commit-ids-matrix-$version.json)
    ORTHANC_TRANSFERS_COMMIT_ID=$(jq -r '.ORTHANC_TRANSFERS_COMMIT_ID' /tmp/commit-ids-matrix-$version.json)
    ORTHANC_DW_COMMIT_ID=$(jq -r '.ORTHANC_DW_COMMIT_ID' /tmp/commit-ids-matrix-$version.json)
    ORTHANC_WSI_COMMIT_ID=$(jq -r '.ORTHANC_WSI_COMMIT_ID' /tmp/commit-ids-matrix-$version.json)
    ORTHANC_OWV_COMMIT_ID=$(jq -r '.ORTHANC_OWV_COMMIT_ID' /tmp/commit-ids-matrix-$version.json)
    ORTHANC_AUTH_COMMIT_ID=$(jq -r '.ORTHANC_AUTH_COMMIT_ID' /tmp/commit-ids-matrix-$version.json)
    ORTHANC_PYTHON_COMMIT_ID=$(jq -r '.ORTHANC_PYTHON_COMMIT_ID' /tmp/commit-ids-matrix-$version.json)
    ORTHANC_ODBC_COMMIT_ID=$(jq -r '.ORTHANC_ODBC_COMMIT_ID' /tmp/commit-ids-matrix-$version.json)
    ORTHANC_INDEXER_COMMIT_ID=$(jq -r '.ORTHANC_INDEXER_COMMIT_ID' /tmp/commit-ids-matrix-$version.json)
    ORTHANC_NEURO_COMMIT_ID=$(jq -r '.ORTHANC_NEURO_COMMIT_ID' /tmp/commit-ids-matrix-$version.json)
    ORTHANC_TCIA_COMMIT_ID=$(jq -r '.ORTHANC_TCIA_COMMIT_ID' /tmp/commit-ids-matrix-$version.json)
    ORTHANC_STONE_VIEWER_COMMIT_ID=$(jq -r '.ORTHANC_STONE_VIEWER_COMMIT_ID' /tmp/commit-ids-matrix-$version.json)
    ORTHANC_AZURE_STORAGE_COMMIT_ID=$(jq -r '.ORTHANC_AZURE_STORAGE_COMMIT_ID' /tmp/commit-ids-matrix-$version.json)
    ORTHANC_GOOGLE_STORAGE_COMMIT_ID=$(jq -r '.ORTHANC_GOOGLE_STORAGE_COMMIT_ID' /tmp/commit-ids-matrix-$version.json)
    ORTHANC_AWS_STORAGE_COMMIT_ID=$(jq -r '.ORTHANC_AWS_STORAGE_COMMIT_ID' /tmp/commit-ids-matrix-$version.json)
    ORTHANC_OE2_COMMIT_ID=$(jq -r '.ORTHANC_OE2_COMMIT_ID' /tmp/commit-ids-matrix-$version.json)
    ORTHANC_OE2_VERSION=$(jq -r '.ORTHANC_OE2_VERSION' /tmp/commit-ids-matrix-$version.json)
    ORTHANC_VOLVIEW_COMMIT_ID=$(jq -r '.ORTHANC_VOLVIEW_COMMIT_ID' /tmp/commit-ids-matrix-$version.json)
    ORTHANC_OHIF_COMMIT_ID=$(jq -r '.ORTHANC_OHIF_COMMIT_ID' /tmp/commit-ids-matrix-$version.json)
    ORTHANC_STL_COMMIT_ID=$(jq -r '.ORTHANC_STL_COMMIT_ID' /tmp/commit-ids-matrix-$version.json)
    ORTHANC_JAVA_COMMIT_ID=$(jq -r '.ORTHANC_JAVA_COMMIT_ID' /tmp/commit-ids-matrix-$version.json)
    ORTHANC_ADVANCED_STORAGE_COMMIT_ID=$(jq -r '.ORTHANC_ADVANCED_STORAGE_COMMIT_ID' /tmp/commit-ids-matrix-$version.json)
    ORTHANC_ADVANCED_STORAGE_VERSION=$(jq -r '.ORTHANC_ADVANCED_STORAGE_VERSION' /tmp/commit-ids-matrix-$version.json)
    ORTHANC_WORKLISTS_COMMIT_ID=$(jq -r '.ORTHANC_WORKLISTS_COMMIT_ID' /tmp/commit-ids-matrix-$version.json)
    ORTHANC_PIXELS_MASKER_COMMIT_ID=$(jq -r '.ORTHANC_PIXELS_MASKER_COMMIT_ID' /tmp/commit-ids-matrix-$version.json)
    ORTHANC_EDUCATION_COMMIT_ID=$(jq -r '.ORTHANC_EDUCATION_COMMIT_ID' /tmp/commit-ids-matrix-$version.json)
    ORTHANC_TESTS_COMMIT_ID=$(jq -r '.ORTHANC_TESTS_COMMIT_ID' /tmp/commit-ids-matrix-$version.json)
fi

BASE_UBUNTU_IMAGE=questing-20251217
BASE_BUILDER_IMAGE_TAG=$BASE_UBUNTU_IMAGE-$version

# list all intermediate targets.  It allows us to "slow down" the build and see what's going wrong (which is not possible with 10 parallel builds)
buildTargets="build-plugin-java build-plugin-auth build-orthanc build-gdcm build-plugin-pg build-plugin-mysql build-plugin-transfers build-plugin-dicomweb build-plugin-wsi build-plugin-owv build-plugin-python build-plugin-odbc build-plugin-indexer build-plugin-neuro build-plugin-tcia build-s3-object-storage build-oe2 build-plugin-volview build-plugin-ohif build-plugin-stl build-plugin-advanced-storage build-plugin-worklists build-plugin-pixels-masker"

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
    buildTargets="$finalImageTarget"

    prefer_downloads=1
    enable_upload=1
fi


# runner_base_tag=$final_image_temporary_tag
# builder_base_tag=$final_image_temporary_tag
# builder_vcpkg_tag="vcpkg-$final_image_temporary_tag"
# builder_vcpkg_azure_tag="vcpkg-azure-$final_image_temporary_tag"
# builder_vcpkg_google_tag="vcpkg-google-$final_image_temporary_tag"

add_host_cmd=--add-host=orthanc.uclouvain.be:130.104.229.21
# to simulate uclouvain servers being unreachables
# add_host_cmd=--add-host=orthanc.uclouvain.be:1.1.1.1

###### runner-base
docker $build \
    $add_host_cmd \
    --progress=plain --platform=$platform -t orthancteam/orthanc-runner-base:$BASE_BUILDER_IMAGE_TAG \
    --build-arg BASE_UBUNTU_IMAGE=$BASE_UBUNTU_IMAGE  \
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
    --build-arg PLATFORM=$platform \
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
        --build-arg ORTHANC_TESTS_COMMIT_ID=$ORTHANC_TESTS_COMMIT_ID \
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
        --build-arg ORTHANC_ADVANCED_STORAGE_COMMIT_ID=$ORTHANC_ADVANCED_STORAGE_COMMIT_ID \
        --build-arg ORTHANC_ADVANCED_STORAGE_VERSION=$ORTHANC_ADVANCED_STORAGE_VERSION \
        --build-arg ORTHANC_WORKLISTS_COMMIT_ID=$ORTHANC_WORKLISTS_COMMIT_ID \
        --build-arg ORTHANC_EDUCATION_COMMIT_ID=$ORTHANC_EDUCATION_COMMIT_ID \
        --build-arg ORTHANC_PIXELS_MASKER_COMMIT_ID=$ORTHANC_PIXELS_MASKER_COMMIT_ID \
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