set -o errexit
set -o xtrace

branch_tag_name=${1:-unknown}

docker build --build-arg IMAGE_TAG=$branch_tag_name -f orthanc-under-tests/Dockerfile -t orthanc-under-tests orthanc-under-tests

# CHANGE_ORTHANC_TESTS_VERSION
orthanc_tests_revision=281a599f5338
docker build --build-arg ORTHANC_TESTS_REVISION=$orthanc_tests_revision -f orthanc-tests/Dockerfile --target orthanc-tests -t orthanc-tests orthanc-tests
docker build --build-arg ORTHANC_TESTS_REVISION=$orthanc_tests_revision -f orthanc-tests/Dockerfile --target orthanc-tests-dicomweb -t orthanc-tests-dicomweb orthanc-tests
docker build --build-arg ORTHANC_TESTS_REVISION=$orthanc_tests_revision -f orthanc-tests/Dockerfile --target orthanc-tests-worklists -t orthanc-tests-worklists orthanc-tests
docker build --build-arg ORTHANC_TESTS_REVISION=$orthanc_tests_revision -f orthanc-tests/Dockerfile --target orthanc-tests-recycling -t orthanc-tests-recycling orthanc-tests
docker build --build-arg ORTHANC_TESTS_REVISION=$orthanc_tests_revision -f orthanc-tests/Dockerfile --target orthanc-tests-transfers -t orthanc-tests-transfers orthanc-tests
docker build --build-arg ORTHANC_TESTS_REVISION=$orthanc_tests_revision -f orthanc-tests/Dockerfile --target orthanc-tests-wsi -t orthanc-tests-wsi orthanc-tests
docker build --build-arg ORTHANC_TESTS_REVISION=$orthanc_tests_revision -f orthanc-tests/Dockerfile --target orthanc-tests-webdav -t orthanc-tests-webdav orthanc-tests
docker build --build-arg ORTHANC_TESTS_REVISION=$orthanc_tests_revision -f orthanc-tests/Dockerfile --target orthanc-tests-cget -t orthanc-tests-cget orthanc-tests

COMPOSE_FILE=docker-compose.sqlite.yml                      docker-compose down -v
COMPOSE_FILE=docker-compose.sqlite.yml                      docker-compose up --build --exit-code-from orthanc-tests --abort-on-container-exit

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

# TODO: reenable sqlserver odbc drivers
# COMPOSE_FILE=docker-compose.odbc-sql-server.yml          docker-compose down -v
# COMPOSE_FILE=docker-compose.odbc-sql-server.yml          docker-compose up --build --exit-code-from orthanc-tests --abort-on-container-exit

# note: not functional yet:
# COMPOSE_FILE=docker-compose.odbc-mysql.yml               docker-compose down -v
# COMPOSE_FILE=docker-compose.odbc-mysql.yml               docker-compose up --build --exit-code-from orthanc-tests --abort-on-container-exit
