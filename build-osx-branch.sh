#!/bin/bash

# sample command
# ./build-osx-branch.sh version=stable configName="Orthanc-tcia" workspace="/tmp/orthanc-builder"

set -ex

# https://stackoverflow.com/a/4774063/881731
SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

source $SCRIPTPATH/bash-helpers.sh


for argument in "$@"
do
   key=$(echo $argument | cut -f1 -d=)

   key_length=${#key}
   value="${argument:$key_length+1}"

   export "$key"="$value"
done



getCommitId() { # $1 = name, $2 = version (stable or unstable)

    revision=$(getBranchTagToBuild $1 $2)
    repo=$(getFromMatrix $1 repo)
    commit_id=$(hg identify $repo -r $revision)
    echo $commit_id
}

commit_id=$(getCommitId $configName $version)
branchTag=$(getBranchTagToBuildOSX $configName $version)
repo=$(getFromMatrix $configName repo)
repoType=$(getFromMatrix $configName repoType)
extraCMakeFlags=$(getFromMatrix $configName extraCMakeFlags)
sourcesSubPath=$(getFromMatrix $configName sourcesSubPath)
unitTests=$(getFromMatrix $configName unitTests)
artifacts=$(getFromMatrix $configName artifactsOSX)
prebuildStep=$(getPrebuildStepOSX $configName $version)
customBuild=$(getCustomBuildOSX $configName $version)
extraCMakeFlagsOSX=$(getFromMatrix $configName extraCMakeFlagsOSX)


echo "configName = $configName"
echo "version = $version"
echo "branchTag = $branchTag"
echo "workspace = $workspace"
echo "repo = $repo"
echo "repoType = $repoType"
echo "extraCMakeFlags = $extraCMakeFlags"
echo "sourcesSubPath = $sourcesSubPath"
echo "unitTests = $unitTests"
echo "artifacts = $artifacts"
echo "prebuildStep = $prebuildStep"
echo "customBuild = $customBuild"
echo "extraCMakeFlagsOSX = $extraCMakeFlagsOSX"

if [[ $repoType == "hg" ]]; then

    hg clone $repo $workspace/sources
    cd $workspace/sources
    hg update -r $branchTag

elif [[ $repoType == "git" ]]; then

    git clone $repo $workspace/sources
    cd $workspace/sources
    git checkout $branchTag

fi

# to know if a build has already been performed, check on S3 if a file has already been generated with this commit id
read -a artifacts_array <<< "$artifacts"
first_artifact=${artifacts_array[0]}

last_commit_id=$(cd $workspace/sources && hg id -i)
already_built=$(($(curl --silent -I https://orthanc.osimis.io/nightly-osx-builds/$first_artifact.$last_commit_id | grep -E "^HTTP"     | awk -F " " '{print $2}') == 200))

if [[ $already_built == 0 ]]; then

    if [[ "$prebuildStep" ]]; then
        eval $prebuildStep
    fi

    ########## build

    if [[ "$customBuild" ]]; then
        
        eval $customBuild
    
    else
    
        # generic build steps
        cmake -B $workspace/build $extraCMakeFlags $extraCMakeFlagsOSX -DCMAKE_OSX_DEPLOYMENT_TARGET=10.9 -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DSTATIC_BUILD=ON -DUNIT_TESTS_WITH_HTTP_CONNEXIONS:BOOL=OFF -DCMAKE_C_FLAGS="-Wno-implicit-function-declaration"  $workspace/sources$sourcesSubPath
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
            cp $workspace/build/$artifact /tmp/artifacts/$artifact.$branchTag
        fi

    done

    aws s3 --region eu-west-1 cp /tmp/artifacts/ s3://orthanc.osimis.io/nightly-osx-builds/ --recursive --cache-control=max-age=1

fi
