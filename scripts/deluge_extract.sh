#!/bin/bash

set -o noclobber    #   Avoid overlay files (echo "hi" > foo)
set -o errexit      #   Used to exit upon error, avoiding cascading errors
set -o pipefail     #   Unviels hidded failures
set -o nounset      #   Exposes unset variables

#   See: https://dev.deluge-torrent.org/wiki/Plugins/Execute

formats=(zip rar)
commands=([zip]="unzip -u") [rar]="unrar -o- e")
extraction_subdir='extracted'

torrent_id=${1}
torrent_name=${2}
torrent_path=${3}

log() {
    logger -t deluge-extractarchives "$@"
}

log "Torrent complete: $@"

cd  "${torrent_path}"

for format in "${formats[@]}"; do
    while read file; do
        log "Extracting \"${file}\""
        cd "$(dirname "$file")"
        file=$(basename "${file}")

        if [[ ! -z "${extraction_subdir}" ]]; then
            mkdir "${extraction_subdir}"
            cd "${extraction_subdir}"
            file="../${file}"
        fi

        ${commands[$format]} "${file}"
    done < <(find "${torrent_path/$torrent_naame" -iname "*.${format}"
done

