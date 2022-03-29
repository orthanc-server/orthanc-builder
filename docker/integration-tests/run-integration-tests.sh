set -o errexit
set -o xtrace

branch_tag_name=${1:-unknown}

docker build --build-arg IMAGE_TAG=$branch_tag_name -f orthanc-under-tests/Dockerfile -t orthanc-under-tests orthanc-under-tests

# CHANGE_ORTHANC_TESTS_VERSION
docker build --build-arg ORTHANC_TESTS_REVISION=default -f orthanc-tests/Dockerfile -t orthanc-tests orthanc-tests


COMPOSE_FILE=docker-compose.sqlite.yml                      docker-compose down -v
COMPOSE_FILE=docker-compose.sqlite.yml                      docker-compose up --build --exit-code-from orthanc-tests --abort-on-container-exit

COMPOSE_FILE=docker-compose.postgres.yml                    docker-compose down -v
COMPOSE_FILE=docker-compose.postgres.yml                    docker-compose up --build --exit-code-from orthanc-tests --abort-on-container-exit

COMPOSE_FILE=docker-compose.odbc-postgres.yml               docker-compose down -v
COMPOSE_FILE=docker-compose.odbc-postgres.yml               docker-compose up --build --exit-code-from orthanc-tests --abort-on-container-exit

COMPOSE_FILE=docker-compose.odbc-sqlite.yml                 docker-compose down -v
COMPOSE_FILE=docker-compose.odbc-sqlite.yml                 docker-compose up --build --exit-code-from orthanc-tests --abort-on-container-exit

COMPOSE_FILE=docker-compose.mysql.yml                       docker-compose down -v
COMPOSE_FILE=docker-compose.mysql.yml                       docker-compose up --build --exit-code-from orthanc-tests --abort-on-container-exit

# TODO run other tests
# TODO: reenable sqlserver odbc drivers
# COMPOSE_FILE=docker-compose.odbc-sql-server.yml          docker-compose down -v
# COMPOSE_FILE=docker-compose.odbc-sql-server.yml          docker-compose up --build --exit-code-from orthanc-tests --abort-on-container-exit

# note: not functional yet:
# COMPOSE_FILE=docker-compose.odbc-mysql.yml               docker-compose down -v
# COMPOSE_FILE=docker-compose.odbc-mysql.yml               docker-compose up --build --exit-code-from orthanc-tests --abort-on-container-exit
