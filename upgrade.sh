#!/usr/bin/env bash

set -o errexit  # Used to exit upon error, avoiding cascading errors
set -o pipefail # Unveils hidden failures
# set -o xtrace   # Print commands and their arguments as they are executed.

application="${1}"

function help() {
    echo """
    Usage: ${0} <application>

    Available applciations are: $(find applications -mindepth 1 -maxdepth 1 -type d -printf '%f ')
    """
    exit 1
}

[[ -z "${application}" ]] && help || echo "Application: ${application}"

[[ ! -d "applications/${application}" ]] && help

if [ ! -d "/home/docker/${application}" ];
then
    echo "No 'home' directory"
    exit 1
fi

microk8s helm upgrade --install "${application}" server --values="applications/${application}/values.yaml" --namespace="${application}" --create-namespace --atomic
