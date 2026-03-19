#!/bin/bash

# sample command
# ./build-volview-dist.sh version=stable workspace="/tmp/volview-dist-builder" avoidHgClone=1

set -ex

source bash-helpers.sh

avoidHgClone=0

for argument in "$@"
do
   key=$(echo $argument | cut -f1 -d=)

   key_length=${#key}
   value="${argument:$key_length+1}"

   export "$key"="$value"
done

configName=Orthanc-volview
repo=$(getFromMatrix $configName repo)

if [[ "$avoidHgClone" == "1" ]]; then
    commit_id=$(jq -r '.ORTHANC_VOLVIEW_COMMIT_ID' /tmp/commit-ids-matrix-$version.json)
else
    commit_id=$(getCommitId $configName $version)
fi

echo "version = $version"
echo "commit_id = $commit_id"
echo "workspace = $workspace"

already_built=$(($(curl --silent -I https://public-files.orthanc.team/tmp-builds/nightly-volview-dist-builds/$commit_id/dist.zip | grep -E "^HTTP"     | awk -F " " '{print $2}') == 200))

if [[ $already_built == 0 ]]; then
    downloadOrClone $repo $commit_id $workspace/sources
    cd $workspace/sources

    cd $workspace/sources/Resources/
    ./CreateVolViewDist.sh

    cd $workspace/sources/VolView/dist/
    zip -r dist.zip .

    aws s3 --region eu-west-1 cp $workspace/sources/VolView/dist/dist.zip s3://public-files.orthanc.team/tmp-builds/nightly-volview-dist-builds/$commit_id/ --cache-control=max-age=1
    aws s3 --region eu-west-1 cp $workspace/sources/VolView/dist/dist.zip s3://public-files.orthanc.team/tmp-builds/nightly-volview-dist-builds/$version/  --cache-control=max-age=1
fi
