#!/bin/bash

# sample command
# ./build-osx-branch.sh configName="Orthanc-tcia" repo="https://hg.orthanc-server.com/orthanc-tcia/" branches="default;OrthancTcia-1.1" workspace="/tmp/orthanc-builder" sourcesSubPath="" unitTests="" extraCMakeFlags="" artifacts="libOrthancTcia.dylib"

set -ex

for argument in "$@"
do
   key=$(echo $argument | cut -f1 -d=)

   key_length=${#key}
   value="${argument:$key_length+1}"

   export "$key"="$value"
done

# use here your expected variables
echo "configName = $configName"
echo "workspace = $workspace"
echo "repo = $repo"
echo "branches = $branches"
echo "extraCMakeFlags = $extraCMakeFlags"
echo "sourcesSubPath = $sourcesSubPath"
echo "unitTests = $unitTests"
echo "artifacts = $artifacts"

hg clone $repo $workspace/sources


export IFS=";"  # separator for lists

for branch in $branches; do

    cd $workspace/sources
    hg update -r $branch

    # to know if a build has already been performed, check on S3 if a file has already been generated with this commit id
    read -a artifacts_array <<< "$artifacts"
    first_artifact=${artifacts_array[0]}

    last_commit_id=$(cd $workspace/sources && hg id -i)
    already_built=$(($(curl --silent -I https://orthanc.osimis.io/nightly-osx-builds/$first_artifact.$last_commit_id | grep -E "^HTTP"     | awk -F " " '{print $2}') == 200))

    if [[ $already_built == 0 ]]; then

        ######### pre-build steps
        if [[ $configName == "Orthanc-stone" ]]; then
            mkdir -p /tmp/downloads

            # TODO: need to download the wasm-binaries for the right branch/version
            # CHANGE_VERSION_STONE_WEB_VIEWER
            wget https://lsb.orthanc-server.com/stone-webviewer/2.3/wasm-binaries.zip --output-document /tmp/downloads/wasm-binaries.zip --quiet
            unzip /tmp/downloads/wasm-binaries.zip -d /tmp/downloads
        fi

        ########## build

        if [[ $configName == "Orthanc-gdcm" ]]; then
            # specific build for GDCM which can not be built in a single step
            cmake -B $workspace/build-arm64 $extraCMakeFlags -DCMAKE_OSX_DEPLOYMENT_TARGET=10.9 -DCMAKE_OSX_ARCHITECTURES="arm64" -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DSTATIC_BUILD=ON -DSTATIC_BUILD=ON -DUNIT_TESTS_WITH_HTTP_CONNEXIONS:BOOL=OFF -DCMAKE_C_FLAGS="-Wno-implicit-function-declaration"  $workspace/sources$sourcesSubPath
            cd $workspace/build-arm64
            make -j 6
            cmake -B $workspace/build-amd64 $extraCMakeFlags -DCMAKE_OSX_DEPLOYMENT_TARGET=10.9 -DCMAKE_OSX_ARCHITECTURES="x86_64" -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DSTATIC_BUILD=ON -DSTATIC_BUILD=ON -DUNIT_TESTS_WITH_HTTP_CONNEXIONS:BOOL=OFF -DCMAKE_C_FLAGS="-Wno-implicit-function-declaration"  $workspace/sources$sourcesSubPath
            cd $workspace/build-amd64
            make -j 6
            mkdir $workspace/build
            lipo -create -output $workspace/build/libOrthancGdcm.dylib $workspace/build-amd64/libOrthancGdcm.dylib $workspace/build-arm64/libOrthancGdcm.dylib
        
        else
            # generic build steps
            cmake -B $workspace/build extraCMakeFlags -DCMAKE_OSX_DEPLOYMENT_TARGET=10.9 -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DSTATIC_BUILD=ON -DUNIT_TESTS_WITH_HTTP_CONNEXIONS:BOOL=OFF -DCMAKE_C_FLAGS="-Wno-implicit-function-declaration"  $workspace/sources$sourcesSubPath
            cd $workspace/build
            make -j 6

        fi

        ########## test
        if [[ $unitTests ]]; then
            $unitTests
        fi

        ########## post-build


        ########## upload
        mkdir /tmp/artifacts

        for artifact in $artifacts; do

            if [ -f "$workspace/build/$artifact" ]; then  # some artifacts may not exist for some branches

                cp $workspace/build/$artifact /tmp/artifacts/$artifact.$last_commit_id
                cp $workspace/build/$artifact /tmp/artifacts/$artifact.$branch
            fi

        done
            # if [[ $artifact1 ]]; then
            #     cp $workspace/build/$artifact /tmp/artifacts/$artifact1.$last_commit_id
            #     cp $workspace/build/$artifact /tmp/artifacts/$artifact1.$branch
            # fi

            # if [[ $artifact2 ]]; then
            #     cp $workspace/build/$artifact /tmp/artifacts/$artifact2.$last_commit_id
            #     cp $workspace/build/$artifact /tmp/artifacts/$artifact2.$branch
            # fi

            # if [[ $artifact3 ]]; then
            #     cp $workspace/build/$artifact /tmp/artifacts/$artifact3.$last_commit_id
            #     cp $workspace/build/$artifact /tmp/artifacts/$artifact3.$branch
            # fi

            # if [[ $artifact4 ]]; then
            #     cp $workspace/build/$artifact /tmp/artifacts/$artifact4.$last_commit_id
            #     cp $workspace/build/$artifact /tmp/artifacts/$artifact4.$branch
            # fi

        aws s3 --region eu-west-1 cp /tmp/artifacts/ s3://orthanc.osimis.io/nightly-osx-builds/ --recursive --cache-control=max-age=1

    fi

done # for branch loop 
