#!/usr/bin/env bash
set -o errexit
set -o xtrace
./ciBuildOrthancBuilderImage.sh
./ciBuildOsimisOrthancDockerImage.sh
./ciBuildOsimisOrthancProDockerImage.sh
