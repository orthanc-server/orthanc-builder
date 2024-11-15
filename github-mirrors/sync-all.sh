set -ex

# this scripts synchronizes the mercurial repositories from https://orthanc.uclouvain.be/hg/
# and the github mirrors on https://github.com/orgs/orthanc-mirrors/
# usage:
# ./sync-all.sh

source mirror-helpers.sh

if [ -d ".env" ]; then
    source .env/bin/activate
else
    initVirtualEnv
fi

syncAllBranchesFromRepo orthanc
syncAllBranchesFromRepo orthanc-gdcm
syncAllBranchesFromRepo orthanc-dicomweb
syncAllBranchesFromRepo orthanc-databases

# todo: add more repos !!!!