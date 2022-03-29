set -o errexit
set -o xtrace

branch_tag_name=${1:-unknown}

docker build --build-arg IMAGE_TAG=$branch_tag_name -f orthanc-under-tests/Dockerfile -t orthanc-under-tests orthanc-under-tests

# CHANGE_ORTHANC_TESTS_VERSION
docker build --build-arg ORTHANC_TESTS_REVISION=default -f orthanc-tests/Dockerfile -t orthanc-tests orthanc-tests


COMPOSE_FILE=docker-compose.sqlite.yml                   docker-compose up --build --exit-code-from orthanc-tests --abort-on-container-exit


# TODO run other tes