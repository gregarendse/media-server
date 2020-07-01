#! /usr/bin/env bash

set -e
set -x

docker-compose --file "${1}" pull   \
    --ignore-pull-failures          \
    --quiet
echo "Docker Compose pull: ${?}"

docker-compose --file "${1}" up \
    --detach                    \
    --quiet-pull                \
    --remove-orphans
echo "Docker Compose up: ${?}"

docker-compose --file "${1}" restart jackett
echo "Docker Compose restrt[jackett]: ${?}"

