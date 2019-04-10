#!/bin/bash

set -o noclobber    #   Avoid overlay files (echo "hi" > foo)
set -o errexit      #   Used to exit upon error, avoiding cascading errors
set -o pipefail     #   Unviels hidded failures
set -o nounset      #   Exposes unset variables

torrent_id=${1}
torrent_name=${2}
torrent_path=${3}

log() {
    logger -t deluge-extractarchives "$@"
}

log "Torrent Removed: $@"

rm -rf "${torrent_path}"

