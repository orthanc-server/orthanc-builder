#!/bin/bash

# sample command
# ./build-stone-wasm.sh version=stable workspace="/tmp/stone-wasm-builder"

set -ex

source bash-helpers.sh

for argument in "$@"
do
   key=$(echo $argument | cut -f1 -d=)

   key_length=${#key}
   value="${argument:$key_length+1}"

   export "$key"="$value"
done

configName=Orthanc-stone
commit_id=$(getCommitId $configName $version)
repo=$(getFromMatrix $configName repo)

echo "version = $version"
echo "commit_id = $commit_id"
echo "workspace = $workspace"

already_built=$(($(curl --silent -I https://public-files.orthanc.team/tmp-builds/nightly-stone-wasm-builds/$commit_id/wasm-binaries.zip | grep -E "^HTTP"     | awk -F " " '{print $2}') == 200))

if [[ $already_built == 0 ]]; then
    hgCloneWithRetries $repo $commit_id $workspace/sources
    cd $workspace/sources

    cd $workspace/sources/Applications/StoneWebViewer/WebAssembly
    ./docker-build.sh Release

    cd $workspace/sources
    zip -r wasm-binaries.zip wasm-binaries/

    aws s3 --region eu-west-1 cp $workspace/sources/wasm-binaries.zip s3://public-files.orthanc.team/tmp-builds/nightly-stone-wasm-builds/$commit_id/ --cache-control=max-age=1
    aws s3 --region eu-west-1 cp $workspace/sources/wasm-binaries.zip s3://public-files.orthanc.team/tmp-builds/nightly-stone-wasm-builds/$version/  --cache-control=max-age=1
fi
