#!/bin/bash

# sample command
# ./build-volview-dist.sh version=stable workspace="/tmp/volview-dist-builder"

set -ex

source bash-helpers.sh

for argument in "$@"
do
   key=$(echo $argument | cut -f1 -d=)

   key_length=${#key}
   value="${argument:$key_length+1}"

   export "$key"="$value"
done

configName=Orthanc-volview
commit_id=$(getCommitId $configName $version)
repo=$(getFromMatrix $configName repo)

echo "version = $version"
echo "commit_id = $commit_id"
echo "workspace = $workspace"

hg clone $repo $workspace/sources
cd $workspace/sources
hg update -r $commit_id
last_commit_id=$(hg id -i)

already_built=$(($(curl --silent -I https://orthanc.osimis.io/nightly-volview-dist-builds/$last_commit_id/dist.zip | grep -E "^HTTP"     | awk -F " " '{print $2}') == 200))

if [[ $already_built == 0 ]]; then

    cd $workspace/sources/Resources/
    ./CreateVolViewDist.sh

    cd $workspace/sources/VolView/dist/
    zip -r dist.zip .

    aws s3 --region eu-west-1 cp $workspace/sources/VolView/dist/dist.zip s3://orthanc.osimis.io/nightly-volview-dist-builds/$last_commit_id/ --cache-control=max-age=1
    aws s3 --region eu-west-1 cp $workspace/sources/VolView/dist/dist.zip s3://orthanc.osimis.io/nightly-volview-dist-builds/$version/  --cache-control=max-age=1
fi
