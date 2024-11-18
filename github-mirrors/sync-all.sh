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
syncAllBranchesFromRepo orthanc-authorization
syncAllBranchesFromRepo orthanc-book
syncAllBranchesFromRepo orthanc-databases
syncAllBranchesFromRepo orthanc-dicomweb
syncAllBranchesFromRepo orthanc-gcp
syncAllBranchesFromRepo orthanc-gdcm
syncAllBranchesFromRepo orthanc-indexer
syncAllBranchesFromRepo orthanc-imagej
syncAllBranchesFromRepo orthanc-java
syncAllBranchesFromRepo orthanc-neuro
syncAllBranchesFromRepo orthanc-object-storage
syncAllBranchesFromRepo orthanc-ohif
syncAllBranchesFromRepo orthanc-python
syncAllBranchesFromRepo orthanc-stone
syncAllBranchesFromRepo orthanc-stl
syncAllBranchesFromRepo orthanc-tcia
syncAllBranchesFromRepo orthanc-tests
syncAllBranchesFromRepo orthanc-transfers
syncAllBranchesFromRepo orthanc-volview
syncAllBranchesFromRepo orthanc-webviewer
syncAllBranchesFromRepo orthanc-wsi

