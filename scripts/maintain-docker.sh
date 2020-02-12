#!/usr/bin/env bash

set -o noclobber  # Avoid overlay files (echo "hi" > foo) 
set -o errexit    # Used to exit upon error, avoiding cascading errors 
set -o pipefail   # Unveils hidden failures 
set -o nounset    # Exposes unset variables 

docker-compose --file /home/greg/git/media-server/docker-scripts/docker-compose.yml up --detach --quiet-pull --remove-orphans

docker system prune --all --force

