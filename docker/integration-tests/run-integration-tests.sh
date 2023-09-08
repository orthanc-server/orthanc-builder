set -o errexit
set -o xtrace

# example usage
# sudo rm -rf orthanc-tests-repo-full/
# sudo rm -rf orthanc-tests-repo-normal/
# ./run-integration-tests.sh tagToTest=22.4.0 version=unstable
# ./run-integration-tests.sh tagToTest=22.7.0-full version=stable image=full

source ../../bash-helpers.sh

tagToTest=latest
version=unknown
image=normal

for argument in "$@"
do
   key=$(echo $argument | cut -f1 -d=)

   key_length=${#key}
   value="${argument:$key_length+1}"

   export "$key"="$value"
done

echo "tagToTest          = $tagToTest"
echo "version            = $version"
echo "image              = $image"

# build to orthanc-under-tests image
docker build --build-arg IMAGE_TAG=$tagToTest -f orthanc-under-tests/Dockerfile -t orthanc-under-tests orthanc-under-tests

pushd ../..  # we need to be at 'root' to use bash-helpers !

if [[ "$version" == "unknown" ]]; then
    integ_tests_branch_tag=${2:-default}
else
    integ_tests_branch_tag=$(getIntegTestsRevision $version)
fi

orthanc_tests_revision=$(getHgCommitId https://hg.orthanc-server.com/orthanc-tests/ $integ_tests_branch_tag)

popd  # back to docker/integration-tests folder


############ run NewTests first
testRepoFolder=orthanc-tests-repo-$image
rm -rf $testRepoFolder/
hg clone https://hg.orthanc-server.com/orthanc-tests/ -r $orthanc_tests_revision $testRepoFolder

pushd $testRepoFolder/NewTests

python3 -m venv .env
source .env/bin/activate

pip3 install -r requirements.txt

######## housekeeper

previous_image=osimis/orthanc:22.4.0

docker pull $previous_image

python3 -u main.py --pattern=Housekeeper.* \
                   --orthanc_under_tests_docker_image=orthanc-under-tests \
                   --orthanc_previous_version_docker_image=$previous_image \
                   --orthanc_under_tests_http_port=8043

######## delayed-deletion

previous_image=osimis/orthanc:$tagToTest

python3 -u main.py --pattern=DelayedDeletion.* \
                   --orthanc_under_tests_docker_image=orthanc-under-tests \
                   --orthanc_previous_version_docker_image=$previous_image_for_housekeeper_tests \
                   --orthanc_under_tests_http_port=8043

######## Other new tests

python3 -u main.py --pattern=ExtraMainDicomTags.* \
                   --orthanc_under_tests_docker_image=orthanc-under-tests \
                   --orthanc_under_tests_http_port=8043

python3 -u main.py --pattern=WithIngestTranscoding.* \
                   --orthanc_under_tests_docker_image=orthanc-under-tests \
                   --orthanc_under_tests_http_port=8043

python3 -u main.py --pattern=MaxStorageReject.* \
                   --orthanc_under_tests_docker_image=orthanc-under-tests \
                   --orthanc_under_tests_http_port=8043

python3 -u main.py --pattern=StorageCompression.* \
                   --orthanc_under_tests_docker_image=orthanc-under-tests \
                   --orthanc_under_tests_http_port=8043

python3 -u main.py --pattern=Authorization.* \
                   --orthanc_under_tests_docker_image=orthanc-under-tests \
                   --orthanc_under_tests_http_port=8043

popd
############ end run NewTests

############ run legacy tests

if [[ $image == "normal" ]]; then

    docker build --build-arg ORTHANC_TESTS_REVISION=$orthanc_tests_revision -f orthanc-tests/Dockerfile --target orthanc-tests -t orthanc-tests orthanc-tests
    docker build --build-arg ORTHANC_TESTS_REVISION=$orthanc_tests_revision -f orthanc-tests/Dockerfile --target orthanc-tests-dicomweb -t orthanc-tests-dicomweb orthanc-tests
    docker build --build-arg ORTHANC_TESTS_REVISION=$orthanc_tests_revision -f orthanc-tests/Dockerfile --target orthanc-tests-worklists -t orthanc-tests-worklists orthanc-tests
    docker build --build-arg ORTHANC_TESTS_REVISION=$orthanc_tests_revision -f orthanc-tests/Dockerfile --target orthanc-tests-recycling -t orthanc-tests-recycling orthanc-tests
    docker build --build-arg ORTHANC_TESTS_REVISION=$orthanc_tests_revision -f orthanc-tests/Dockerfile --target orthanc-tests-transfers -t orthanc-tests-transfers orthanc-tests
    docker build --build-arg ORTHANC_TESTS_REVISION=$orthanc_tests_revision -f orthanc-tests/Dockerfile --target orthanc-tests-wsi -t orthanc-tests-wsi orthanc-tests
    docker build --build-arg ORTHANC_TESTS_REVISION=$orthanc_tests_revision -f orthanc-tests/Dockerfile --target orthanc-tests-webdav -t orthanc-tests-webdav orthanc-tests
    docker build --build-arg ORTHANC_TESTS_REVISION=$orthanc_tests_revision -f orthanc-tests/Dockerfile --target orthanc-tests-cget -t orthanc-tests-cget orthanc-tests
    docker build --build-arg ORTHANC_TESTS_REVISION=$orthanc_tests_revision --build-arg IMAGE_TAG=$tagToTest -f orthanc-transcoding-tests/Dockerfile -t orthanc-transcoding-tests orthanc-transcoding-tests

    COMPOSE_FILE=docker-compose.sqlite.yml                      docker-compose down -v
    COMPOSE_FILE=docker-compose.sqlite.yml                      docker-compose up --build --exit-code-from orthanc-tests --abort-on-container-exit

    COMPOSE_FILE=docker-compose.sqlite-compression.yml          docker-compose down -v
    COMPOSE_FILE=docker-compose.sqlite-compression.yml          docker-compose up --build --exit-code-from orthanc-tests --abort-on-container-exit

    COMPOSE_FILE=docker-compose.dicomweb.yml                    docker-compose down -v
    COMPOSE_FILE=docker-compose.dicomweb.yml                    docker-compose up --build --exit-code-from orthanc-tests-dicomweb --abort-on-container-exit

    COMPOSE_FILE=docker-compose.postgres.yml                    docker-compose down -v
    COMPOSE_FILE=docker-compose.postgres.yml                    docker-compose up --build --exit-code-from orthanc-tests --abort-on-container-exit

    COMPOSE_FILE=docker-compose.odbc-postgres.yml               docker-compose down -v
    COMPOSE_FILE=docker-compose.odbc-postgres.yml               docker-compose up --build --exit-code-from orthanc-tests --abort-on-container-exit

    COMPOSE_FILE=docker-compose.odbc-sqlite.yml                 docker-compose down -v
    COMPOSE_FILE=docker-compose.odbc-sqlite.yml                 docker-compose up --build --exit-code-from orthanc-tests --abort-on-container-exit

    COMPOSE_FILE=docker-compose.mysql.yml                       docker-compose down -v
    COMPOSE_FILE=docker-compose.mysql.yml                       docker-compose up --build --exit-code-from orthanc-tests --abort-on-container-exit

    COMPOSE_FILE=docker-compose.webdav.yml                      docker-compose down -v
    COMPOSE_FILE=docker-compose.webdav.yml                      docker-compose up --build --exit-code-from orthanc-tests-webdav --abort-on-container-exit

    COMPOSE_FILE=docker-compose.cget.yml                        docker-compose down -v
    COMPOSE_FILE=docker-compose.cget.yml                        docker-compose up --build --exit-code-from orthanc-tests-cget --abort-on-container-exit

    COMPOSE_FILE=docker-compose.s3.yml                         docker-compose down -v
    COMPOSE_FILE=docker-compose.s3.yml                         docker-compose up --build --exit-code-from orthanc-tests --abort-on-container-exit

    COMPOSE_FILE=docker-compose.wsi.yml                         docker-compose down -v
    COMPOSE_FILE=docker-compose.wsi.yml                         docker-compose up --build --exit-code-from orthanc-tests-wsi --abort-on-container-exit

    COMPOSE_FILE=docker-compose.transfers.yml                   docker-compose down -v
    COMPOSE_FILE=docker-compose.transfers.yml                   docker-compose up --build --exit-code-from orthanc-tests-transfers --abort-on-container-exit

    COMPOSE_FILE=docker-compose.recycling.yml                   docker-compose down -v
    COMPOSE_FILE=docker-compose.recycling.yml                   docker-compose up --build --exit-code-from orthanc-tests-recycling --abort-on-container-exit

    COMPOSE_FILE=docker-compose.worklists.yml                   docker-compose down -v
    COMPOSE_FILE=docker-compose.worklists.yml                   docker-compose up --build --exit-code-from orthanc-tests-worklists --abort-on-container-exit

    COMPOSE_FILE=docker-compose.ingest-transcoding.yml          docker-compose down -v
    COMPOSE_FILE=docker-compose.ingest-transcoding.yml          docker-compose up --build --exit-code-from orthanc-under-tests --abort-on-container-exit

    COMPOSE_FILE=docker-compose.scu-transcoding.yml             docker-compose down -v
    COMPOSE_FILE=docker-compose.scu-transcoding.yml             docker-compose up --build --exit-code-from orthanc-under-tests --abort-on-container-exit

# note: not functional yet:
# COMPOSE_FILE=docker-compose.odbc-mysql.yml               docker-compose down -v
# COMPOSE_FILE=docker-compose.odbc-mysql.yml               docker-compose up --build --exit-code-from orthanc-tests --abort-on-container-exit

# TODO: add tests:
# - CheckHttpServerSecurity.py
# - CheckDicomTls.py
# - CheckZipStream.py

else  # full images (MSSQL only !)

    docker build --build-arg ORTHANC_TESTS_REVISION=$orthanc_tests_revision -f orthanc-tests/Dockerfile --target orthanc-tests -t orthanc-tests orthanc-tests

    COMPOSE_FILE=docker-compose.odbc-sql-server.yml             docker-compose down -v
    COMPOSE_FILE=docker-compose.odbc-sql-server.yml             docker-compose up --build --exit-code-from orthanc-tests --abort-on-container-exit

fi


