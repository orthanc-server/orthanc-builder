#!/bin/bash

set -ex

# repo=https://hg.orthanc-server.com/orthanc-tcia
# branch=default
# workspace=workspace
# extraCMakeFlags=
# sourcesSubPath=
# unitTests=
# artifact=
# artifact2=
# artifact3=
# artifact4=


# #!/usr/bin/env bash

# while [ $# -gt 0 ]; do
#   case "$1" in
#     --repo)
#       repo="$2"
#       ;;
#     --branch)
#       branch="$2"
#       ;;
#     --workspace)
#       workspace="$2"
#       ;;
#     --extraCMakeFlags)
#       extraCMakeFlags="$2"
#       ;;
#     --sourcesSubPath)
#       sourcesSubPath="$2"
#       ;;
#     --unitTests)
#       unitTests="$2"
#       ;;
#     --artifact1)
#       artifact1="$2"
#       ;;
#     --artifact2)
#       artifact2="$2"
#       ;;
#     --artifact3)
#       artifact3="$2"
#       ;;
#     --artifact4)
#       artifact4="$2"
#       ;;
#     *)
#       printf "***************************\n"
#       printf "* Error: Invalid argument.*\n"
#       printf "***************************\n"
#       exit 1
#   esac
#   shift
#   shift
# done

for argument in "$@"
do
   key=$(echo $argument | cut -f1 -d=)

   key_length=${#key}
   value="${argument:$key_length+1}"

   export "$key"="$value"
done

# use here your expected variables
echo "workspace = $workspace"
echo "repo = $repo"
echo "branch = $branch"
echo "extraCMakeFlags = $extraCMakeFlags"
echo "sourcesSubPath = $sourcesSubPath"
echo "unitTests = $unitTests"
echo "artifact = $artifact"
echo "artifact2 = $artifact2"
echo "artifact3 = $artifact3"
echo "artifact4 = $artifact4"

hg clone $repo -r $branch $workspace/sources

last_commit_id=$(cd $workspace/sources && hg id -i)
already_built=$(($(curl --silent -I https://orthanc.osimis.io/nightly-osx-builds/$artifact.$last_commit_id | grep -E "^HTTP"     | awk -F " " '{print $2}') == 200))

if [[ $already_built == 0 ]]; then

    cmake -B $workspace/build extraCMakeFlags -DCMAKE_OSX_DEPLOYMENT_TARGET=10.9 -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DSTATIC_BUILD=ON -DUNIT_TESTS_WITH_HTTP_CONNEXIONS:BOOL=OFF -DCMAKE_C_FLAGS="-Wno-implicit-function-declaration"  $workspace/sources$sourcesSubPath
    cd $workspace/build
    make -j 6

    if [[ $unitTests ]]; then
        $unitTests
    fi

    cp $workspace/build/$artifact $workspace/build/$artifact.$last_commit_id
    cp $workspace/build/$artifact $workspace/build/$artifact.$branch
    aws s3 --region eu-west-1 cp $workspace s3://orthanc.osimis.io/nightly-osx-builds/ --recursive --exclude "*" --include "$artifact.*" --cache-control=max-age=1

fi
 
